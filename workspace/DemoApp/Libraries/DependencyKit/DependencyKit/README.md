#  Umbrella Module Only

This 'DependencyKit' framework, nested within DemoApp, exists only as an umbrella module.
This module requires the DependencyKit library via SPM and links it statically. *This* module
is then dynamically linked with all of the modules within DemoApp which require it. 

This is necessay because the local SPM module can only by statically linked, and it's not possible
to statically link with multiple modules in the same app. (i.e. NetworkClient and DependencyKit in DemoApp). 

N.B. This module does not itself contain any actual code;
