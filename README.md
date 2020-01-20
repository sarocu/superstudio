# :office: :department_store: :hospital: :european_castle: SuperStudio  :european_castle: :hospital: :department_store: :office:

## The Nice to use, OpenStudio automation CLI
| Feature | Usage | Description | 
|---------|-------|-------------|
| Set an ASHRAE building type | `--building_type [...]` | Adds space types, loads and schedules from OpenStudio-Standards |
| Set an ASHRAE Standard | `--standard [...]` | Adds basic systems and schedules |
| Set the Climate Zone | `--climate_zone [...]` | Adds construction sets and loads|
| Add weather data | `--weather [-epw ...] [-ddy ...]` | Asign EPW and DDY files |
| Merge geometry from JSON | `--geometry [--json ...]` | Swap out standard geometry with JSON formatted from FloorspaceJS |
| Create thermal zones | `--geometry --zoning per-space` | Create thermal zones according to a given scheme; currently only one zone per space is supported |
| Set WWR | `--geometry --wwr 0.3` | Set the window-wall ratio of all exterior walls |
| Scale floor area | `--geometry --floor_area 2000` | Scales the X and Y axis of the existing geometry to match the provided floor area in square meters |

This project is still in its early stages and not exactly production ready - I will be fixing bugs and applying a number of new features including:
* ~~Geometry scaling~~
* ~~Apply window-to-wall ratios~~
* ~~Plugin template system~~
* Stock HVAC system templates
* Space type assignment for FloorspaceJS files
* Basic simulation run manager
* Results extraction
* Basic plotting

## Getting Started
Dependencies:
* [OpenStudio 2.9.0 or higher](https://github.com/NREL/OpenStudio/releases/tag/v2.9.1)
* [OpenStudio-Standards 0.2.10 or higher](https://rubygems.org/gems/openstudio-standards/versions/0.2.10)
* [Ruby 2.2.7](https://www.ruby-lang.org/en/downloads/releases/) (the OpenStudio ruby bindings require a 2.2.x install)

Eventually this will be available through Ruby Gems but for the moment, installing the package requires you to clone it down and manually install:
```bash
gem build superstudio.gemspec
gem install superstudio-0.1.0.gem
irb
> require 'superstudio'
> => true
```

or with Rake:
```bash
rake install

# test the CLI by creating a baseline model:
rake test_create
```

## Adding a Template Plugin
Templates contain bits of code to drop in HVAC systems and make sure loads and schedules are properly applied - basically the stuff you need to get the model up and running. Templates in SuperStudio can draw from the OpenStudio SDK itself, OpenStudio-Standards, or the convenience methods in `lib/templates`. 

A local settings folder contains the path to your local templates directory (currently just edit the file `bin/superstudio-settings.json`, this will change in the future). Each Ruby module in this directory is imported at runtime. A template should minimimally include a method that provides an entrypoint - this is the method that gets called when you specify a template on the CLI. So that means:
```bash
./bin/superstudio ...  --template bootstrapCentralHwChwVavBasic
```
Will call the method `bootstrapCentralHwChwVavBasic` using Ruby's `__send__` 