defmodule Elmpack do
  use Application
  import Supervisor
  import FileSystem

  def start(_type, _args) do
 
    dispatch_config = build_dispatch_config

    # {:ok, sentix_pid} = Sentix.start_link(:watcher_name, ["/Users/martin.karrer/Documents/Development/elm_ui/"])
    {:ok, pid} = FileSystem.start_link(dirs: ["/Users/martin.karrer/Development/elm_webpage/"], name: :my_monitor_name)
    {:ok, pid} = GenServer.start_link(Elmpack.Eventhandler, [])

    {:ok, _} =
      :cowboy.start_clear(
        :http,
        [{:port, 8080}],
        %{:env => %{:dispatch => dispatch_config}}
      )
  end

  def build_dispatch_config do
    :cowboy_router.compile([
      {:_,
       [
         {"/error.html", :cowboy_static, {:file, "/Users/martin.karrer/Development/elm_webpage/main.html"}},
         {"/main.js", :cowboy_static, {:file, "/Users/martin.karrer/Development/elm_webpage/main.js"}},
         {"/main.css", :cowboy_static, {:file, "/Users/martin.karrer/Development/elm_webpage/main.css"}},
         {"/[...]", :cowboy_static, {:file, "/Users/martin.karrer/Development/elm_webpage/main.html"}},
         {"/static/[...]", :cowboy_static, {:priv_dir, :elmpack, "static_files"}},
       ]}
    ])
  end
end


defmodule Elmpack.Eventhandler do
  use GenServer

  def start_link(_args) do
    IO.puts "Eventhandler started"
    IO.puts "Subscribed"
    GenServer.start_link(__MODULE__, _args, name: Elmpack.Eventhandler)
  end

  def init(args) do
    IO.puts "Init Done"
    retval = FileSystem.subscribe(:my_monitor_name)
    #system_resp = System.cmd("cd",  ["/Users/martin.karrer/Documents/Development/elm_webpage; elm make src/Main.elm --output=main.js --optimize"])
    :ok = File.cd("/Users/martin.karrer/Development/elm_webpage")
    system_resp = System.cmd("elm",  ["make", "src/Main.elm", "--output=main.js", "--optimize"])
    IO.inspect system_resp
    {:ok, %{}}
  end

  def handle_info(info, state) do
    #IO.inspect info
#    system_resp = System.cmd("elm",  ["make", "src/Main.elm", "--output=main.js", "--optimize"])
    {:file_event, pid, filemeta} = info
    {file, event} = filemeta
    cond do
      String.ends_with?(file, [".elm", ".html", ".md"])
        ->  System.cmd("elm",  ["make", "src/Main.elm", "--output=main.js", "--optimize"])
      true -> IO.puts "No Compile"
    end
    {:noreply, state}
  end

end
