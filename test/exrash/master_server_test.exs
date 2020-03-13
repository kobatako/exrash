defmodule Exrash.MasterServerTest do
  use ExUnit.Case

  test "fetch add worker" do
    assert Exrash.MasterServer.fetch_add_worker_num(0, 5, nil) == { :ok, 5 }

    assert Exrash.MasterServer.fetch_add_worker_num(5, 5, 10) == { :ok, 5 }
    assert Exrash.MasterServer.fetch_add_worker_num(4, 5, 10) == { :ok, 5 }

    assert Exrash.MasterServer.fetch_add_worker_num(9, 5, 10) == { :ok, 1 }
    assert Exrash.MasterServer.fetch_add_worker_num(6, 5, 10) == { :ok, 4 }
    assert Exrash.MasterServer.fetch_add_worker_num(6, 10, 10) == { :ok, 4 }

    assert Exrash.MasterServer.fetch_add_worker_num(10, 5, 10) == { :ok, 0 }
    assert Exrash.MasterServer.fetch_add_worker_num(11, 5, 10) == { :ok, 0 }
  end

  test "error fetch add worker" do
    assert Exrash.MasterServer.fetch_add_worker_num("0", 5, 10) == { :error, "is not type" }
    assert Exrash.MasterServer.fetch_add_worker_num(0, "5", 10) == { :error, "is not type" }
    assert Exrash.MasterServer.fetch_add_worker_num(1, 5, "10") == { :error, "is not type" }

    assert Exrash.MasterServer.fetch_add_worker_num(1.1, 5.1, 10) == { :error, "is not type" }
    assert Exrash.MasterServer.fetch_add_worker_num(0, 5.1, 10) == { :error, "is not type" }
    assert Exrash.MasterServer.fetch_add_worker_num(0, 5, 10.1) == { :error, "is not type" }

    assert Exrash.MasterServer.fetch_add_worker_num(-1, 5, 10) == { :error, "is not type" }
    assert Exrash.MasterServer.fetch_add_worker_num(0, -5, 10) == { :error, "is not type" }
    assert Exrash.MasterServer.fetch_add_worker_num(0, 5, -1) == { :error, "is not type" }
  end
end
