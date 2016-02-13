if !isfile(joinpath(dirname(@__FILE__), "default_units.jl"))
    info("Setting the default display units. To change the default values or add a new custom `display_unit` it can be added in $(escape_string(joinpath(dirname(@__FILE__), "default_units.jl")))")
    open(joinpath(dirname(@__FILE__), "default_units.jl"), "w") do f
        print(f, """
        "Reset the display of units to the default values. To change the default values or add a new custom `display_unit` it can be added in $(escape_string(joinpath(dirname(@__FILE__), "default_units.jl")))"
        function default_units()
            display_unit(Newton, "N")
            display_unit(Pascal, "Pa")
            display_unit(Joule, "J")
            display_unit(Watt, "W")
            display_unit(Coulomb, "C")
            display_unit(Volt, "V")
            display_unit(Coulomb/Volt, "F")
            display_unit(Ohm, "Ω")
            display_unit(Siemens, "S")
            display_unit(u"Wb", "Wb")
            display_unit(u"T", "T")
            display_unit(u"H", "H")
            display_unit(u"lm", "lm")
            display_unit(u"lx", "lx")
        end""")
    end
end
