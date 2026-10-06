defmodule JustBash.Commands.GrepTest do
  use ExUnit.Case, async: true

  @json """
  [
    {
      "id": 1,
      "name": "Other malignancy within 5 years",
      "x": 2
    },
    {
      "id": 2,
      "name": "Age ≥ 18 years",
      "x": 3
    }
  ]
  """

  defp run(script, files \\ %{"/data/a.json" => @json}) do
    {result, _bash} = JustBash.exec(JustBash.new(files: files, cwd: "/data"), script)
    result
  end

  describe "context" do
    test "-A and -B print surrounding lines" do
      result = run(~s(grep -A 1 -B 1 "Other malignancy" a.json))
      assert result.exit_code == 0

      assert result.stdout ==
               ~s(    "id": 1,\n    "name": "Other malignancy within 5 years",\n    "x": 2\n)
    end

    test "attached values and -C" do
      assert run(~s(grep -A1 "Age" a.json)).stdout =~ ~s("x": 3)
      assert run(~s(grep -C1 "Age" a.json)).stdout =~ ~s("id": 2)
      assert run(~s(grep -1 "Age" a.json)).stdout =~ ~s("id": 2)
    end

    test "separates non-adjacent groups with --" do
      assert run(~s(grep -A 0 -B 0 -C 0 '"id"' a.json)).stdout == ~s(    "id": 1,\n    "id": 2,\n)
      assert run(~s(grep -A 1 '"id"' a.json)).stdout =~ "\n--\n"
    end

    test "-n marks context lines with - and matches with :" do
      assert run(~s(grep -n -B 1 "Age" a.json)).stdout ==
               ~s(8:    "id": 2,\n9:    "name": "Age ≥ 18 years",\n) |> String.replace("8:", "8-")
    end
  end

  describe "patterns" do
    test "-e is repeatable" do
      assert run(~s(grep -c -e Other -e Age a.json)).stdout == "2\n"
    end

    test "basic regex treats \\| as alternation and | as a literal" do
      assert run(~s(grep -c 'Other\\|Age' a.json)).stdout == "2\n"
      assert run(~s(grep -c 'Other|Age' a.json)).exit_code == 1
    end

    test "-E uses extended regex" do
      assert run(~s(grep -cE 'Other|Age' a.json)).stdout == "2\n"
      assert run(~s(grep -cE '"id": [0-9]+' a.json)).stdout == "2\n"
    end

    test "-F matches fixed strings" do
      assert run(~s(grep -F '≥ 18' a.json)).exit_code == 0
      assert run(~s(grep -cF '.' a.json)).stdout == "0\n"
    end

    test "-w and -x" do
      assert run(~s(grep -cw 'year' a.json)).stdout == "0\n"
      assert run(~s(grep -cw 'years' a.json)).stdout == "2\n"
      assert run(~s(grep -x '\\[' a.json)).stdout == "[\n"
    end

    test "-i is case-insensitive for non-ASCII too" do
      assert run(~s(grep -ci 'OTHER' a.json)).stdout == "1\n"
    end

    test "an invalid regex is an error, not a silent literal" do
      result = run(~s(grep -E '(' a.json))
      assert result.exit_code == 2
      assert result.stderr =~ "invalid regular expression"
    end
  end

  describe "output modes" do
    test "-m stops after NUM selected lines" do
      assert run(~s(grep -m 1 '"id"' a.json)).stdout == ~s(    "id": 1,\n)
    end

    test "-o prints each match" do
      assert run(~s(grep -oE '"id": [0-9]+' a.json)).stdout == ~s("id": 1\n"id": 2\n)
    end

    test "-l and -L" do
      files = %{"/data/a.json" => @json, "/data/b.txt" => "nothing\n"}
      assert run("grep -l Age a.json b.txt", files).stdout == "a.json\n"

      result = run("grep -L Age a.json b.txt", files)
      assert result.stdout == "b.txt\n"
      assert result.exit_code == 0
    end

    test "-c with -v counts non-matching lines" do
      assert run(~s(grep -cv '"' a.json)).stdout == "6\n"
    end

    test "-q prints nothing" do
      result = run("grep -q Age a.json")
      assert result.stdout == ""
      assert result.exit_code == 0
    end
  end

  describe "files" do
    test "-r prefixes the filename even for one file" do
      assert run(~s(grep -rn 'Age' /data)).stdout ==
               ~s(/data/a.json:9:    "name": "Age ≥ 18 years",\n)
    end

    test "-r with no operand searches the working directory" do
      assert run(~s(grep -rl 'Age')).stdout == "./a.json\n"
    end

    test "--include and --exclude filter recursive files" do
      files = %{"/data/a.json" => @json, "/data/b.txt" => "Age\n", "/data/sub/c.json" => "Age\n"}

      assert run(~s(grep -rl --include='*.json' Age .), files).stdout ==
               "./a.json\n./sub/c.json\n"

      assert run(~s(grep -rl --exclude='*.json' Age .), files).stdout == "./b.txt\n"
      assert run(~s(grep -rl --exclude-dir=sub Age .), files).stdout == "./a.json\n./b.txt\n"
    end

    test "-h hides and -H shows the filename" do
      files = %{"/data/a.txt" => "x\n", "/data/b.txt" => "x\n"}
      assert run("grep -h x a.txt b.txt", files).stdout == "x\nx\n"
      assert run("grep -H x a.txt", files).stdout == "a.txt:x\n"
    end

    test "a missing file reports an error and exits 2" do
      result = run("grep Age a.json missing.txt")
      assert result.exit_code == 2
      assert result.stderr == "grep: missing.txt: No such file or directory\n"
      assert result.stdout =~ "a.json:"
    end

    test "-s suppresses file errors" do
      result = run("grep -s Age missing.txt")
      assert result.stderr == ""
      assert result.exit_code == 2
    end

    test "a directory without -r is an error" do
      assert run("grep Age /data").stderr == "grep: /data: Is a directory\n"
    end

    test "stdin, including the - operand" do
      assert run("printf 'a\\nb\\n' | grep b").stdout == "b\n"
      assert run("printf 'b\\n' | grep -H b -").stdout == "(standard input):b\n"
    end
  end

  describe "errors" do
    test "an unknown option exits 2" do
      result = run("grep --bogus x a.json")
      assert result.exit_code == 2
      assert result.stderr =~ "unrecognized option '--bogus'"
    end

    test "a missing option value exits 2" do
      assert run("grep x -A").exit_code == 2
    end
  end
end
