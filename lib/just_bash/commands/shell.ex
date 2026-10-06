defmodule JustBash.Commands.Shell do
  @moduledoc """
  The `bash` and `sh` commands - run a script in a child shell.

  Supported forms:

    * `bash FILE [ARG...]` - run a script file, with `$1..$N` set to the args.
    * `bash -c COMMAND [NAME [ARG...]]` - run a command string; `NAME` is `$0`.
    * `bash` with no operand - run the script read from stdin.

  `-e`, `-u` and `-o pipefail` set the child's shell options. `-x`, `-v`,
  `-l`, `-i` and `--norc`/`--noprofile` are accepted and ignored.

  The child runs in this same interpreter, so it is bound by the same limits.
  Like a real child process, its variables, functions, working directory and
  shell options do not reach the caller. Its filesystem writes do, because the
  filesystem is shared, and so do the limit counters (steps, output bytes and
  exec depth), so a script cannot reset its budget by nesting `bash -c`.
  """
  @behaviour JustBash.Commands.Command

  alias JustBash.Fs.InMemoryFs
  alias JustBash.Interpreter.Executor
  alias JustBash.Parser

  @ignored ~w(-x -v -l -i --norc --noprofile --login)

  @impl true
  def names, do: ["bash", "sh"]

  @impl true
  def execute(bash, args, stdin) do
    case parse(args, %{}) do
      {:ok, opts, {:command, script, positionals}} ->
        run(bash, script, positionals, opts)

      {:ok, opts, {:file, file, positionals}} ->
        case InMemoryFs.read_file(bash.fs, InMemoryFs.resolve_path(bash.cwd, file)) do
          {:ok, script} -> run(bash, script, [file | positionals], opts)
          {:error, :eisdir} -> failure(bash, "bash: #{file}: Is a directory\n", 126)
          {:error, _} -> failure(bash, "bash: #{file}: No such file or directory\n", 127)
        end

      {:ok, opts, :stdin} ->
        run(bash, stdin, ["bash"], opts)

      {:error, message} ->
        failure(bash, message, 2)
    end
  end

  defp parse(["-c"], _opts), do: {:error, "bash: -c: option requires an argument\n"}

  defp parse(["-c", script | rest], opts) do
    positionals = if rest == [], do: ["bash"], else: rest
    {:ok, opts, {:command, script, positionals}}
  end

  defp parse(["-e" | rest], opts), do: parse(rest, Map.put(opts, :errexit, true))
  defp parse(["-u" | rest], opts), do: parse(rest, Map.put(opts, :nounset, true))

  defp parse(["-o", "pipefail" | rest], opts),
    do: parse(rest, Map.put(opts, :pipefail, true))

  defp parse(["-o", name | _rest], _opts),
    do: {:error, "bash: #{name}: invalid option name\n"}

  defp parse([flag | rest], opts) when flag in @ignored, do: parse(rest, opts)
  defp parse(["--" | rest], opts), do: parse_operands(rest, opts)

  # Combined short flags such as `-eu` or `-ex`.
  defp parse(["-" <> letters = flag | rest], opts) when byte_size(letters) > 1 do
    expanded = letters |> String.graphemes() |> Enum.map(&("-" <> &1))

    if Enum.all?(expanded, &(&1 in ["-e", "-u", "-c" | @ignored])),
      do: parse(expanded ++ rest, opts),
      else: {:error, "bash: #{flag}: invalid option\n"}
  end

  defp parse(["-" <> _ = flag | _rest], _opts) when flag != "-",
    do: {:error, "bash: #{flag}: invalid option\n"}

  defp parse(rest, opts), do: parse_operands(rest, opts)

  defp parse_operands([], opts), do: {:ok, opts, :stdin}
  defp parse_operands(["-" | _], opts), do: {:ok, opts, :stdin}
  defp parse_operands([file | args], opts), do: {:ok, opts, {:file, file, args}}

  defp run(bash, script, [name | args], opts) do
    case Parser.parse(script) do
      {:ok, ast} ->
        child = %{
          bash
          | env: child_env(bash.env, name, args),
            shell_opts: Map.merge(bash.shell_opts, opts)
        }

        {result, finished} = Executor.execute_script(child, ast)

        # Only what a real child process would leave behind: the shared
        # filesystem, and the limit counters that bound the whole execution.
        interpreter = %{
          bash.interpreter
          | step_count: finished.interpreter.step_count,
            output_bytes: finished.interpreter.output_bytes,
            max_exec_depth: finished.interpreter.max_exec_depth
        }

        {Map.take(result, [:stdout, :stderr, :exit_code]),
         %{bash | fs: finished.fs, interpreter: interpreter}}

      {:error, error} ->
        failure(bash, "bash: #{name}: #{error.message}\n", 2)
    end
  end

  defp child_env(env, name, args) do
    env
    |> Enum.reject(fn {key, _} ->
      key in ["#", "@", "*"] or match?({_, ""}, Integer.parse(key))
    end)
    |> Map.new()
    |> Map.merge(
      args
      |> Enum.with_index(1)
      |> Map.new(fn {arg, index} -> {Integer.to_string(index), arg} end)
    )
    |> Map.merge(%{
      "0" => name,
      "#" => Integer.to_string(length(args)),
      "@" => Enum.join(args, " "),
      "*" => Enum.join(args, " ")
    })
  end

  defp failure(bash, message, code), do: {%{stdout: "", stderr: message, exit_code: code}, bash}
end
