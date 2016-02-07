using EngUnits
using Base.Test

for p in keys(EngUnits.prefixes)
	for u in keys(EngUnits.prefix_units)
		@test EngUnits.parse_units(p*u) == EngUnits.prefixes[p]*EngUnits.prefix_units[u]
	end
end


@test_throws ArgumentError EngUnits.parse_units("max(mm^2,1)") 
@test_throws ArgumentError EngUnits.parse_units("1")