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

This project is still in its early stages and not exactly production ready - I will be fixing bugs and applying a number of new features including:
* Geometry scaling
* Apply window-to-wall ratios
* HVAC system templates
* Space type assignment for FloorspaceJS files
* Basic simulation run manager
* Results extraction
* Basic plotting

## Getting Started
Dependencies:
* [OpenStudio 2.9.0 or higher](https://github.com/NREL/OpenStudio/releases/tag/v2.9.1)
* [OpenStudio-Standards 0.2.10 or higher](https://rubygems.org/gems/openstudio-standards/versions/0.2.10)
* [Ruby 2.2.7](https://www.ruby-lang.org/en/downloads/releases/) (the OpenStudio ruby bindings require a 2.2.x install)

Eventually this will be available through Ruby Gems but for the moment, installing the packae requires you to clone it down and manually install:
```bash
gem build superstudio.gemspec
gem install superstudio-0.1.0.gem
irb
> require 'superstudio'
> => true
```
