defmodule JustBash.Commands.ShellTest do
  use ExUnit.Case, async: true

  defp run(script, opts \\ []) do
    bash = JustBash.new(Keyword.merge([cwd: "/w"], opts))
    JustBash.exec(bash, script)
  end

  test "bash FILE runs a script written by a heredoc" do
    {result, _} =
      run("""
      cat << 'EOF' > job.sh
      echo "args: $1 $2 ($#)"
      echo done > out.txt
      EOF
      bash job.sh one two
      cat out.txt
      """)

    assert result.stdout == "args: one two (2)\ndone\n"
    assert result.exit_code == 0
  end

  test "sh is the same command" do
    {result, _} = run("echo 'echo hi' > s.sh; sh s.sh")
    assert result.stdout == "hi\n"
  end

  test "bash -c runs a command string with $0 and positionals" do
    {result, _} = run(~s(bash -c 'echo "$0 $1"' name arg))
    assert result.stdout == "name arg\n"
  end

  test "bash with no operand reads the script from stdin" do
    {result, _} = run("echo 'echo from-stdin' | bash")
    assert result.stdout == "from-stdin\n"
  end

  test "child variables, functions and cwd do not reach the caller" do
    {result, bash} = run(~s|X=1; bash -c 'X=2; f() { :; }; cd /'; echo "$X"|)
    assert result.stdout == "1\n"
    assert bash.cwd == "/w"
    refute Map.has_key?(bash.functions, "f")
  end

  test "child filesystem writes persist" do
    {result, _} = run("bash -c 'echo x > made.txt'; cat made.txt")
    assert result.stdout == "x\n"
  end

  test "exit status passes through, and exit does not stop the caller" do
    {result, _} = run("bash -c 'exit 3'; echo \"rc=$?\"")
    assert result.stdout == "rc=3\n"
  end

  test "-e stops the child at the first failure" do
    {result, _} = run("bash -e -c 'false; echo unreachable'")
    assert result.stdout == ""
    assert result.exit_code == 1
  end

  test "a missing script exits 127" do
    {result, _} = run("bash nope.sh")
    assert result.exit_code == 127
    assert result.stderr =~ "No such file or directory"
  end

  test "nested bash -c cannot reset the step limit" do
    {result, _} =
      run(
        "for i in 1 2 3 4 5 6 7 8 9 10; do bash -c 'for j in 1 2 3 4 5 6 7 8 9 10; do :; done'; done",
        limits: [max_steps: 50]
      )

    assert result.exit_code != 0
    assert result.stderr =~ "limit"
  end
end
