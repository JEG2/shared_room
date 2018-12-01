Host:  elixir --name 'room@192.168.1.139' --cookie 'beamnetworkingftw' -S mix run -e 'Application.ensure_started(:shared_room)' --no-halt -- HOST
Client:  elixir --name 'room@192.168.1.141' --cookie 'beamnetworkingftw' -S mix run -e 'Application.ensure_started(:shared_room)' --no-halt -- 'room@192.168.1.139'
