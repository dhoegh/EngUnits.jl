module EngUnits
    using SIUnits
    import Base.show
    SI = SIUnits
    
    const default_units_file = joinpath(dirname(@__FILE__), "..", "deps", "default_units.jl")
    isfile(default_units_file) || error("EngUnits not properly installed. Please run Pkg.build(\"EngUnits\")")
    
    "Earths standard gravity"
    const g = 9.80665*Meter /Second^2
    
    module Imperial
        using SIUnits
        import EngUnits
        const inch = 25.4*Milli*Meter
        const lbm = KiloGram/2.2046 
        const lbf = lbm * EngUnits.g
        const psi = 1*lbf/inch^2
        const ksi = Kilo*psi
        const ft = 12*inch
		const yard = 36*inch
        const mile = 1609.344*Meter
        const gallon = 4.54609*10^3*CentiMeter^3
    end
    import .Imperial
    imp = Imperial

    prefixes = Dict("k" => Kilo,
                    "M" => Mega,
                    "G" => Giga,
                    "T" => Tera,
                    "P" => Peta,
                    "E" => Exa,
                    "Z" => Zetta,
                    "Y" => SI.Yotta,
					"d" => (1//10)SIPrefix,
                    "c" => Centi,
                    "m" => Milli,
                    "μ" => Micro,
                    "n" => Nano,
                    "p" => Pico,
                    "f" => Femto,
                    "a" => Atto,
                    "z" => Zepto,
                    "y" => Yocto)

    function parse_display_units(unit::AbstractString)
        super = false
        out = IOBuffer()
        for c in unit
            if c=='^'
                super = true
                continue
            elseif !(c in ['-','0','1','2','3','4','5','6','7','8','9'])
                super = false
            end
            if super
                write(out, c   ==  '-' ? '\u207b' :
                            c   ==  '1' ? '\u00b9' :
                            c   ==  '2' ? '\u00b2' :
                            c   ==  '3' ? '\u00b3' :
                            c   ==  '4' ? '\u2074' :
                            c   ==  '5' ? '\u2075' :
                            c   ==  '6' ? '\u2076' :
                            c   ==  '7' ? '\u2077' :
                            c   ==  '8' ? '\u2078' :
                            c   ==  '9' ? '\u2079' :
                            c   ==  '0' ? '\u2070' :
                            error("Unexpected Chatacter"))
            elseif c!='^'
                write(out, c)
            end
        end
        takebuf_string(out)
    end

    const _display_unit = Dict{SI.UnitTuple,Tuple{UTF8String, Number}}()
    #One could argument that it should not specialize on rad, sr as they are unitless
    """The function enable the user to select the display unit as:
    ```
    julia> a = 1000u"N*m"
    1000.0 J
    julia> display_unit(u"kN*m", "kN m")

    julia> b = 1u"kN*m"
    1.0 kN m

    julia> Int(a) == Int(b)
    true
    ```
    Even though the display unit is kN m the calculations is done using the siunit and the value of a and b are therefore the same. the only difference is how the value is displayed to the user.
    """
    function display_unit_eval(units::SI.UnitTuple)
        m,kg,s,A,K,mol,cd,rad,sr = units
        if !haskey(_display_unit, units)
            @eval function show{T<:Number}(io::IO,x::SI.SIQuantity{T,$m,$kg,$s,$A,$K,$mol,$cd,$rad,$sr})
                i = Base.ht_keyindex(_display_unit, $units)
                if i>0
                    u, d = _display_unit.vals[i]
                else #Fall back to original method if the custom display is removed
                    return invoke(show, Tuple{IO, SI.SIQuantity}, io, x)
                end
                show(io,x.val/d)
                print(io," ")
                print(io, u)
            end
        end
    end
    function display_unit{m,kg,s,A,K,mol,cd,rad,sr}(u::SI.SIUnit{m,kg,s,A,K,mol,cd,rad,sr}, unit::AbstractString)
        units = (m,kg,s,A,K,mol,cd,rad,sr)
        display_unit_eval(units)
        _display_unit[units] = (parse_display_units(unit), 1)
        nothing
    end
    function display_unit{T<:Number,m,kg,s,A,K,mol,cd,rad,sr}(u::SI.SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr}, unit::AbstractString)
        units = (m,kg,s,A,K,mol,cd,rad,sr)
        display_unit_eval(units)
        _display_unit[units] = (parse_display_units(unit), u.val)
        nothing
    end
    function display_unit{T<:Number,m,kg,s,A,K,mol,cd,rad,sr}(f::Function, u::Union{SI.SIQuantity{T,m,kg,s,A,K,mol,cd,rad,sr},
                    SI.SIUnit{m,kg,s,A,K,mol,cd,rad,sr}} , unit::AbstractString)
        units = (m,kg,s,A,K,mol,cd,rad,sr)
        display_unit_eval(units)
        _display_unit[units] = (parse_display_units(unit), u.val)
        try
            f()
        finally
            pop!(_display_unit, units)
        end
    end
    

    const si_units = Dict("m"=>Meter, #SI units
                    "kg"=>KiloGram, 
                    "s"=>Second,
                    "A"=>Ampere,
                    "K"=>Kelvin,
                    "mol"=>Mole,
                    "cd"=>Candela,
                    "rad"=>Radian)
	const derived_units = Dict("sr"=>Steradian, # Derived units
                    "Hz"=>Hertz,
                    "N"=>Newton,
                    "Pa"=>Pascal,
                    "J"=>Joule,
                    "W"=>Watt,
                    "C"=>Coulomb,
                    "V"=>Volt,
                    "F"=>Farad,
                    "Ω"=>Ohm,
                    "S"=>Siemens,
                    "Wb"=>Volt*Second,
                    "T"=>Volt*Second/Meter^2,
                    "H"=>Volt*Second/Ampere,
                    "lm"=>Candela*Steradian,
                    "lx"=>Meter^-2*Candela,
                    "Bq"=>Second^-1,
                    "Gy"=>Joule/KiloGram,
                    "Sv"=>Joule/KiloGram,
                    "kat"=>Mole*Second^-1)
					
    const misc_units = Dict("deg"=>Degree,
                    "bar"=>0.1*Mega*Pascal,
                    "hour"=>3600*Second,
                    "min"=>60*Second,
                    "rpm"=>2pi*Radian/(60*Second),
                    "atm"=> Atmosphere,
                     # Imperial units
                    "inch"=>imp.inch,
                    "lbm"=>imp.lbm,
                    "lbf"=>imp.lbf,
                    "psi"=>imp.psi,
                    "ksi"=>imp.ksi,
                    "ft"=>imp.ft,
					"yd"=>imp.yard,
                    "mile"=>imp.mile,
                    "gallon"=>imp.gallon)
	const prefix_units = merge(si_units,derived_units)
	
	type UnitParseError <: Exception
		s::UTF8String
	end

    function replace_value(sym::Symbol)
        s = string(sym)
		if length(s) > 1
			p = first(s)
			un = replace(s, p, "", 1)
			u_i = Base.ht_keyindex(prefix_units, un)
			p_i = Base.ht_keyindex(prefixes, "$p")
			if !(u_i<0) && !(p_i<0)
				return prefixes.vals[p_i]*prefix_units.vals[u_i]
			end
		end
		u_i = Base.ht_keyindex(prefix_units, s)
		if !(u_i<0)
			 return prefix_units.vals[u_i]
		end
		u_i = Base.ht_keyindex(misc_units, s)
		if !(u_i<0)
			return misc_units.vals[u_i]
        else 
            throw(UnitParseError("No unit named: $s was found"))
        end
    end
	
	replace_value(x) = throw(UnitParseError("$x is not a valid unit"))
	
	const allowed_funcs = [:*, :/, :^, :sqrt, :√, :+, :-, ://]
	
    function replace_value(ex::Expr)
        ex.head != :call && throw(UnitParseError("$(ex.head) != :call"))
		ex.args[1] in allowed_funcs || throw(UnitParseError("""$(ex.args[1]) is not a valid function call when parsing a unit.
												Only the following functions are allow: $allowed_funcs"""))
        for i=2:length(ex.args)
            if typeof(ex.args[i])==Symbol || typeof(ex.args[i])==Expr
				ex.args[i]=replace_value(ex.args[i])
            end
        end
        ex
    end
	
    function parse_units(input)
        ex = parse(input, raise=false)
        inc_tag = Base.incomplete_tag(ex)
        inc_tag==:none || throw(ArgumentError("Incomplete Unit expresion in: $input"))
		try
			replace_value(ex)
		catch exc
			isa(exc, UnitParseError) || throw(exc)
			throw(ArgumentError("""While parsing the unit string: "$input".
								the following UnitParseError occured: $(exc.s)"""))
		end
    end
	"""The string macro is used to expres units and it can be performed as:
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
    ```"""
    macro u_str(unit)
        parse_units(unit)
    end
    
    include(default_units_file) # generated by Pkg.build("EngUnits")
    default_units()
    
    function reset_default_units()
        rm(default_units_file)
        include(joinpath(dirname(@__FILE__), "..", "deps", "build.jl"))
    end

    export display_unit, @u_str, g, default_units, reset_default_units
end

