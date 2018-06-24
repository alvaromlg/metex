# Metex

Weather application using OTP framework using The Little Elixir & OTP Guidebook

Starting GenServer

```
Metex.GenServer.Worker.start_link
```

Requesting temperatures
```
Metex.GenServer.Worker.get_temperature("Málaga")
"26.0°C"
Metex.GenServer.Worker.get_temperature("Barcelona")
"29.0°C"
Metex.GenServer.Worker.get_temperature("Memphis")
"28.2°C"
```

You can call the process directly without using a GenServer

```
iex(3)> cities = ["Málaga", "Barcelona", "Monaco", "Helsinki", "Macau"]       
["Málaga", "Barcelona", "Monaco", "Helsinki", "Macau"]
iex(4)> Metex.temperatures_of(cities)                                  
:ok
Barcelona: 26.0°C, Helsinki: 16.0°C, Macau: 31.3°C, Monaco: 18.8°C, Málaga: 29.0°C
```
