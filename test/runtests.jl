using EngUnits
using Base.Test
import SIUnits

for p in keys(EngUnits.prefixes)
	for u in keys(EngUnits.prefix_units)
		@test EngUnits.parse_units(p*u) == EngUnits.prefixes[p]*EngUnits.prefix_units[u]
	end
end


@test_throws ArgumentError EngUnits.parse_units("max(mm^2,1)") 
@test_throws ArgumentError EngUnits.parse_units("1")

p = 1e6*SIUnits.Pascal
@test p == 1u"MPa"
@test p == 1u"N/mm^2"


@test 1e3u"psi" == 1u"ksi"

io = IOBuffer()

display_unit(u"Pa", "Pa")
show(io, p)
@test takebuf_string(io) == "1.0e6 Pa"
display_unit(u"MPa", "MPa")
show(io, p)
@test takebuf_string(io) == "1.0 MPa"
display_unit(u"N/mm^2", "N/mm^2")
show(io, p)
@test takebuf_string(io) == "1.0 N/mm\u00b2"
