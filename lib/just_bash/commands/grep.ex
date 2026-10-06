defmodule JustBash.Commands.Grep do
  @moduledoc """
  The `grep` command - print lines matching a pattern.

  Follows GNU grep for the options scripts use most:

    * Matching: `-e PAT` (repeatable), `-E`, `-F`, `-G`, `-P`, `-i`/`-y`, `-v`,
      `-w`, `-x`. Without `-E`/`-P`/`-F` the pattern is a POSIX basic regular
      expression, so `a\\|b`, `\\(x\\)` and `x\\{2\\}` work as in GNU grep.
    * Output: `-c`, `-l`, `-L`, `-n`, `-o`, `-q`, `-s`, `-H`, `-h`, `-m NUM`.
    * Context: `-A NUM`, `-B NUM`, `-C NUM` and `-NUM`, with `--` between
      non-adjacent groups and `-` as the separator on context lines.
    * Files: `-r`/`-R` (searches `.` when no file is given), `--include=GLOB`,
      `--exclude=GLOB`, `--exclude-dir=GLOB`, and `-` for stdin.

  Exit status: 0 when a line was selected (or, with `-L`, a file was listed),
  1 when none was, and 2 when an error occurred and `-q` did not see a match.
  """
  @behaviour JustBash.Commands.Command

  alias JustBash.Commands.Command
  alias JustBash.Fs.InMemoryFs
  alias JustBash.Limit

  @defaults %{
    patterns: [],
    mode: :basic,
    i: false,
    v: false,
    w: false,
    x: false,
    c: false,
    l: false,
    files_without_match: false,
    n: false,
    o: false,
    q: false,
    s: false,
    r: false,
    with_filename: false,
    no_filename: false,
    max_count: nil,
    after: 0,
    before: 0,
    include: [],
    exclude: [],
    exclude_dir: []
  }

  @short_booleans %{
    "i" => :i,
    "y" => :i,
    "v" => :v,
    "w" => :w,
    "x" => :x,
    "c" => :c,
    "l" => :l,
    "L" => :files_without_match,
    "n" => :n,
    "o" => :o,
    "q" => :q,
    "s" => :s,
    "r" => :r,
    "R" => :r,
    "H" => :with_filename,
    "h" => :no_filename
  }

  @short_modes %{"E" => :extended, "F" => :fixed, "G" => :basic, "P" => :perl}

  # Accepted and ignored: they change nothing in a text-only virtual filesystem.
  @short_ignored ~w(a I U Z)

  @short_values %{
    "e" => :pattern,
    "m" => :max_count,
    "A" => :after,
    "B" => :before,
    "C" => :context
  }

  @long_booleans %{
    "ignore-case" => :i,
    "invert-match" => :v,
    "word-regexp" => :w,
    "line-regexp" => :x,
    "count" => :c,
    "files-with-matches" => :l,
    "files-without-match" => :files_without_match,
    "line-number" => :n,
    "only-matching" => :o,
    "quiet" => :q,
    "silent" => :q,
    "no-messages" => :s,
    "recursive" => :r,
    "dereference-recursive" => :r,
    "with-filename" => :with_filename,
    "no-filename" => :no_filename
  }

  @long_modes %{
    "extended-regexp" => :extended,
    "fixed-strings" => :fixed,
    "basic-regexp" => :basic,
    "perl-regexp" => :perl
  }

  @long_values %{
    "regexp" => :pattern,
    "max-count" => :max_count,
    "after-context" => :after,
    "before-context" => :before,
    "context" => :context,
    "include" => :include,
    "exclude" => :exclude,
    "exclude-dir" => :exclude_dir
  }

  @long_ignored ~w(color colour text binary null line-buffered)

  @impl true
  def names, do: ["grep"]

  @impl true
  def execute(bash, args, stdin) do
    with {:ok, opts, rest} <- parse(args, @defaults, []),
         {:ok, opts, files} <- take_patterns(opts, rest),
         {:ok, regex} <- compile(bash, opts) do
      run(bash, opts, regex, files, stdin)
    else
      {:error, message} -> {Command.error("grep: #{message}\n", 2), bash}
    end
  end

  ## Argument parsing

  defp parse([], opts, rest), do: {:ok, opts, Enum.reverse(rest)}
  defp parse(["--" | tail], opts, rest), do: {:ok, opts, Enum.reverse(rest, tail)}
  defp parse(["-" | tail], opts, rest), do: parse(tail, opts, ["-" | rest])

  defp parse(["--" <> long | tail], opts, rest) do
    {name, inline} =
      case String.split(long, "=", parts: 2) do
        [name, value] -> {name, value}
        [name] -> {name, nil}
      end

    cond do
      key = @long_booleans[name] ->
        parse(tail, Map.put(opts, key, true), rest)

      mode = @long_modes[name] ->
        parse(tail, %{opts | mode: mode}, rest)

      name in @long_ignored ->
        parse(tail, opts, rest)

      key = @long_values[name] ->
        case {inline, tail} do
          {nil, [value | tail]} -> put_value(key, value, tail, opts, rest)
          {nil, []} -> {:error, "option '--#{name}' requires an argument"}
          {value, _} -> put_value(key, value, tail, opts, rest)
        end

      true ->
        {:error, "unrecognized option '--#{name}'"}
    end
  end

  defp parse(["-" <> short | tail], opts, rest) do
    if Regex.match?(~r/^\d+$/, short),
      do: put_value(:context, short, tail, opts, rest),
      else: parse_short(String.graphemes(short), tail, opts, rest)
  end

  defp parse([arg | tail], opts, rest), do: parse(tail, opts, [arg | rest])

  defp parse_short([], tail, opts, rest), do: parse(tail, opts, rest)

  defp parse_short([letter | more], tail, opts, rest) do
    cond do
      key = @short_booleans[letter] ->
        parse_short(more, tail, Map.put(opts, key, true), rest)

      mode = @short_modes[letter] ->
        parse_short(more, tail, %{opts | mode: mode}, rest)

      letter in @short_ignored ->
        parse_short(more, tail, opts, rest)

      key = @short_values[letter] ->
        case {more, tail} do
          {[], [value | tail]} -> put_value(key, value, tail, opts, rest)
          {[], []} -> {:error, "option requires an argument -- '#{letter}'"}
          {attached, _} -> put_value(key, Enum.join(attached), tail, opts, rest)
        end

      true ->
        {:error, "invalid option -- '#{letter}'"}
    end
  end

  defp put_value(:pattern, value, tail, opts, rest),
    do: parse(tail, %{opts | patterns: opts.patterns ++ [value]}, rest)

  defp put_value(key, value, tail, opts, rest) when key in [:include, :exclude, :exclude_dir],
    do: parse(tail, Map.update!(opts, key, &(&1 ++ [value])), rest)

  defp put_value(key, value, tail, opts, rest) do
    case Integer.parse(value) do
      {number, ""} when number >= 0 ->
        opts =
          case key do
            :context -> %{opts | after: number, before: number}
            key -> Map.put(opts, key, number)
          end

        parse(tail, opts, rest)

      _ ->
        {:error, "invalid number: '#{value}'"}
    end
  end

  defp take_patterns(%{patterns: []}, []), do: {:error, "missing pattern"}

  defp take_patterns(%{patterns: []} = opts, [pattern | files]),
    do: {:ok, %{opts | patterns: [pattern]}, files}

  defp take_patterns(opts, files), do: {:ok, opts, files}

  ## Pattern compilation

  defp compile(bash, opts) do
    Enum.each(opts.patterns, &Limit.check_regex_size!(bash.limits, &1))

    # GNU treats each line of a pattern as a separate pattern.
    source =
      opts.patterns
      |> Enum.flat_map(&String.split(&1, "\n"))
      |> Enum.map_join("|", &"(?:#{translate(&1, opts.mode)})")
      |> wrap(opts)

    flags = if opts.i, do: [:caseless, :unicode, :ucp], else: [:unicode, :ucp]

    case Regex.compile(source, flags) do
      {:ok, regex} -> {:ok, regex}
      {:error, {reason, _at}} -> {:error, "invalid regular expression: #{reason}"}
    end
  end

  defp wrap(source, %{x: true}), do: "^(?:#{source})$"
  defp wrap(source, %{w: true}), do: "(?<!\\w)(?:#{source})(?!\\w)"
  defp wrap(source, _opts), do: source

  defp translate(pattern, :fixed), do: Regex.escape(pattern)
  defp translate(pattern, :extended), do: pattern
  defp translate(pattern, :perl), do: pattern
  defp translate(pattern, :basic), do: basic_to_pcre(pattern, [])

  # POSIX BRE (with the GNU extensions) to PCRE. In a BRE, `\|`, `\(`, `\)`,
  # `\{`, `\}`, `\+` and `\?` are the operators and the bare characters are
  # literals, which is the reverse of an ERE. Bracket expressions are copied
  # through unchanged.
  defp basic_to_pcre(<<>>, acc), do: acc |> Enum.reverse() |> IO.iodata_to_binary()

  defp basic_to_pcre(<<"\\", char::utf8, rest::binary>>, acc) when char in ~c"|(){}+?",
    do: basic_to_pcre(rest, [<<char::utf8>> | acc])

  defp basic_to_pcre(<<"\\", char::utf8, rest::binary>>, acc),
    do: basic_to_pcre(rest, [<<"\\", char::utf8>> | acc])

  defp basic_to_pcre(<<char::utf8, rest::binary>>, acc) when char in ~c"|(){}+?",
    do: basic_to_pcre(rest, [<<"\\", char::utf8>> | acc])

  defp basic_to_pcre(<<"[", rest::binary>>, acc) do
    {bracket, rest} = take_bracket(rest)
    basic_to_pcre(rest, ["[" <> bracket | acc])
  end

  defp basic_to_pcre(<<char::utf8, rest::binary>>, acc),
    do: basic_to_pcre(rest, [<<char::utf8>> | acc])

  defp basic_to_pcre(<<byte, rest::binary>>, acc),
    do: basic_to_pcre(rest, [<<byte>> | acc])

  # A `]` first in a bracket (or after `^`) is a literal member.
  defp take_bracket(rest) do
    {lead, rest} =
      case rest do
        "^]" <> rest -> {"^]", rest}
        "]" <> rest -> {"]", rest}
        "^" <> rest -> {"^", rest}
        rest -> {"", rest}
      end

    case :binary.match(rest, "]") do
      {at, 1} ->
        {lead <> binary_part(rest, 0, at + 1),
         binary_part(rest, at + 1, byte_size(rest) - at - 1)}

      :nomatch ->
        {lead <> rest, ""}
    end
  end

  ## Running

  defp run(bash, opts, regex, files, stdin) do
    files = if files == [] and opts.r, do: ["."], else: files
    files = if files == [], do: ["-"], else: files

    {sources, errors} = expand(bash, files, opts, stdin)

    show_filename = show_filename?(opts, files)

    {chunks, matched?, listed?} =
      Enum.reduce(sources, {[], false, false}, fn {name, content}, {chunks, matched?, listed?} ->
        lines = split_lines(content)
        selected = select(lines, regex, opts)
        label = if name == "-", do: "(standard input)", else: name
        prefix = if show_filename, do: label, else: nil

        {chunk, listed} = render(label, prefix, lines, selected, regex, opts)
        {[chunk | chunks], matched? or selected != [], listed? or listed}
      end)

    stdout = if opts.q, do: "", else: chunks |> Enum.reverse() |> IO.iodata_to_binary()
    stderr = if opts.s, do: "", else: Enum.join(errors)

    {Command.result(stdout, stderr, exit_code(opts, matched?, listed?, errors)), bash}
  end

  defp show_filename?(opts, files),
    do: opts.with_filename or (not opts.no_filename and (opts.r or length(files) > 1))

  defp exit_code(%{q: true}, true = _matched?, _listed?, _errors), do: 0
  defp exit_code(_opts, _matched?, _listed?, [_ | _] = _errors), do: 2
  defp exit_code(%{files_without_match: true}, _matched?, true = _listed?, _errors), do: 0
  defp exit_code(%{files_without_match: false}, true = _matched?, _listed?, _errors), do: 0
  defp exit_code(_opts, _matched?, _listed?, _errors), do: 1

  # Returns `{[{display_name, content}], [error_line]}`, in argument order.
  defp expand(bash, files, opts, stdin) do
    {sources, errors} =
      Enum.reduce(files, {[], []}, fn
        "-", {sources, errors} ->
          {[{"-", stdin} | sources], errors}

        file, {sources, errors} ->
          resolved = InMemoryFs.resolve_path(bash.cwd, file)

          case InMemoryFs.stat(bash.fs, resolved) do
            {:ok, %{is_directory: true}} when opts.r ->
              found =
                bash.fs
                |> walk(resolved, file, opts)
                |> Enum.map(fn {display, full} -> {display, read(bash, full)} end)

              {Enum.reverse(found, sources), errors}

            {:ok, %{is_directory: true}} ->
              {sources, ["grep: #{file}: Is a directory\n" | errors]}

            {:ok, _file} ->
              if included?(file, opts),
                do: {[{file, read(bash, resolved)} | sources], errors},
                else: {sources, errors}

            {:error, _} ->
              {sources, ["grep: #{file}: No such file or directory\n" | errors]}
          end
      end)

    {Enum.reverse(sources), Enum.reverse(errors)}
  end

  defp read(bash, path) do
    case InMemoryFs.read_file(bash.fs, path) do
      {:ok, content} -> content
      {:error, _} -> ""
    end
  end

  defp walk(fs, full, display, opts) do
    case InMemoryFs.readdir(fs, full) do
      {:ok, entries} ->
        entries
        |> Enum.sort()
        |> Enum.flat_map(&walk_entry(fs, full, display, &1, opts))

      {:error, _} ->
        []
    end
  end

  defp walk_entry(fs, full, display, entry, opts) do
    child_full = join(full, entry)
    child_display = join(display, entry)

    case InMemoryFs.stat(fs, child_full) do
      {:ok, %{is_directory: true}} ->
        if Enum.any?(opts.exclude_dir, &glob_match?(&1, entry)),
          do: [],
          else: walk(fs, child_full, child_display, opts)

      {:ok, _} ->
        if included?(entry, opts), do: [{child_display, child_full}], else: []

      {:error, _} ->
        []
    end
  end

  defp join("/", entry), do: "/" <> entry
  defp join(path, entry), do: String.trim_trailing(path, "/") <> "/" <> entry

  defp included?(path, opts) do
    base = Path.basename(path)

    (opts.include == [] or Enum.any?(opts.include, &glob_match?(&1, base))) and
      not Enum.any?(opts.exclude, &glob_match?(&1, base))
  end

  defp glob_match?(glob, name) do
    source =
      glob
      |> Regex.escape()
      |> String.replace("\\*", ".*")
      |> String.replace("\\?", ".")
      |> String.replace("\\[", "[")
      |> String.replace("\\]", "]")

    case Regex.compile("^" <> source <> "$") do
      {:ok, regex} -> Regex.match?(regex, name)
      {:error, _} -> glob == name
    end
  end

  defp split_lines(""), do: []
  defp split_lines(content), do: content |> String.trim_trailing("\n") |> String.split("\n")

  # The 0-based indexes of the selected lines, honouring `-v` and `-m`.
  defp select(lines, regex, opts) do
    selected =
      lines
      |> Enum.with_index()
      |> Enum.filter(fn {line, _index} -> matches?(regex, line) != opts.v end)
      |> Enum.map(&elem(&1, 1))

    case opts.max_count do
      nil -> selected
      max -> Enum.take(selected, max)
    end
  end

  # A line that is not valid UTF-8 cannot match a `:unicode` regex. Treat it as
  # a non-match rather than crash the command.
  defp matches?(regex, line) do
    Regex.match?(regex, line)
  rescue
    ArgumentError -> false
  end

  ## Rendering

  # Returns `{iodata, listed?}`, where `listed?` is whether `-L` printed the name.
  defp render(label, prefix, lines, selected, regex, opts) do
    cond do
      opts.files_without_match ->
        if selected == [], do: {[label, "\n"], true}, else: {[], false}

      opts.l ->
        if selected != [], do: {[label, "\n"], false}, else: {[], false}

      opts.c ->
        {[prefixed(prefix, ":"), Integer.to_string(length(selected)), "\n"], false}

      selected == [] ->
        {[], false}

      opts.o ->
        {render_only(prefix, lines, selected, regex, opts), false}

      true ->
        {render_lines(prefix, lines, selected, opts), false}
    end
  end

  # `-v -o` prints nothing in GNU grep: an inverted line has no match to show.
  defp render_only(_prefix, _lines, _selected, _regex, %{v: true}), do: []

  defp render_only(prefix, lines, selected, regex, opts) do
    tuple = List.to_tuple(lines)

    Enum.map(selected, fn index ->
      regex
      |> Regex.scan(elem(tuple, index), capture: :first)
      |> List.flatten()
      |> Enum.reject(&(&1 == ""))
      |> Enum.map(&[line_prefix(prefix, opts, index, ":"), &1, "\n"])
    end)
  end

  defp render_lines(prefix, lines, selected, opts) do
    tuple = List.to_tuple(lines)
    last = tuple_size(tuple) - 1
    selected_set = MapSet.new(selected)
    context? = opts.before > 0 or opts.after > 0

    shown =
      selected
      |> Enum.flat_map(&Enum.to_list(max(&1 - opts.before, 0)..min(&1 + opts.after, last)//1))
      |> Enum.uniq()
      |> Enum.sort()

    {iodata, _previous} =
      Enum.map_reduce(shown, nil, fn index, previous ->
        separator =
          if context? and previous != nil and index > previous + 1, do: "--\n", else: []

        mark = if MapSet.member?(selected_set, index), do: ":", else: "-"
        {[separator, line_prefix(prefix, opts, index, mark), elem(tuple, index), "\n"], index}
      end)

    iodata
  end

  defp line_prefix(prefix, opts, index, mark) do
    number = if opts.n, do: [Integer.to_string(index + 1), mark], else: []
    [prefixed(prefix, mark), number]
  end

  defp prefixed(nil, _mark), do: []
  defp prefixed(prefix, mark), do: [prefix, mark]
end
