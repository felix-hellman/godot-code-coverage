# Code Coverage

Adds code coverage reports to godot

## How to install

### Using gop
```bash
gop init
gop add gop add --dependency=felix-hellman/codecoverage --version=0.0.3
gop install
```

## How to use

Initiate the autoinject node that instruments your objects
```
var auto_inject = load("res://pkg/felix-hellman-codecoverage/AutoInject.gd").new()
add_child(auto_inject)
```

When autoinject exits the tree it will print out information about what it did and where the report has been saved
```
Found report for res://test/CodeToCover.gd
Found report for res://test/LoopsToCover.gd
Report saved at : /home/felix/.local/share/godot/app_userdata/CodeCoverage/coverage_report.json
```

