# Hardware
Engine is developed to  administer supercomputer center hardware and its status.
## API
Devices can be created or updated via WEB API.
You have to specify secret named **hardware_api** and send JSON to `/hardware/admin/items/json_update` using the format below.
Add the secret to the config/secrets.yaml like this:

```
production:
  hardware_api: 1234567890
```

Then upload new data like this: `curl -H X-OctoAPI-Auth: 1234567890 -X POST -d @file.json https://octoshell/hardware/admin/items/json_update`.

Use this format for create/update hardware:
```
{
  "language": "en", # (optional) Chosen language affects validation
  "data":[
    {
      "id":4, # specify id to edit existing device. Don't specify it to create a new device.
      "name_ru":"", # unnecessary
      "name_en":"Switch 1", # name en is required for english language!
      "description_ru":"",  # unnecessary
      "description_en":"",  # unnecessary
      "kind_id":2,  # id of device kind
      "state":{
        "state_id" : 9, transit to state with id = 9
        "reason_ru": "Я хочу", # unnecessary
        "description_ru": "Договор номер такой-то такой-то",  # unnecessary
        "description_en": ""  # unnecessary
      }
    },
    {
      "name_en": "created_via_json6", # name en is required for english language!
      "kind_id": "2", #  # id of device kind
      "state":{
        "state_id" : 8, # transit to state with id = 8
        "reason_ru": "Я хочу", # unnecessary
        "description_ru": "Договор номер такой-то такой-то", # unnecessary
        "description_en": "" # unnecessary
      }
    }
  ]
}
```
