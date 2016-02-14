Linux: [![Build Status](https://travis-ci.org/dhoegh/EngUnits.jl.svg?branch=master)](https://travis-ci.org/dhoegh/EngUnits.jl)
&nbsp;
Windows: [![Build status](https://ci.appveyor.com/api/projects/status/2wv5q6l7obp0y3k7?svg=true)](https://ci.appveyor.com/project/dhoegh/engunits-jl)
# EngUnits
This library extends SIUnits.jl to handle Engineering units through a string macro. Variables with units can be written as:
```
julia> a = 3*25.4u"mm"
0.07619999999999999 m
julia> b = 4 * u"inch"
0.1016 m
julia> sqrt(a^2 + b^2)==5u"inch"
```
All units inputted with the unit string `u""`, will be converted to the SI unit equvilant, hence one inch is converted to `0.00254 m`. SI prefixes and operators can also be used in a unit string as:
```
julia> 1.0u"N/mm^2"
1.0e6 Pa
```
As it is an extension of SIUnits.jl it can also multiply units as:
```
julia> 1u"N"/1u"m^2"
1.0 Pa
```
The package do also enable the user to select the display unit as:
```
julia> a = 1000u"N*m"
1000.0 J
julia> display_unit(u"kN*m", "kN m")

julia> b = 1u"kN*m"
1.0 kN m

julia> unitless(a) == unitless(b)
true
```
Even though the display unit is kN m the calculations is performed using the siunit and the value of a and b are therefore the same. the only difference is how the value is displayed to the user.

# Known issues/limitations
* `u"in"` do not give inches use `u"inch"` instead. This is caused by `in` is a infix operator in julia and because the unit string macro use julia's parser to parse the unit strings `in` cannot be used to mean inches.
* Not all methods can take units. If a method do not take unitfull arguments then a unit can be converted to a unitless value by calling `unitless` on the variable.

Don't hesitate to file an issue or pull-request to improve the package.

