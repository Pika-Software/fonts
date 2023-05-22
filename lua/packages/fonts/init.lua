require( "packages/units", "https://github.com/Pika-Software/units" )

local packageName = gpm.Package:GetIdentifier()
local logger = gpm.Logger
local pairs = pairs

module( "fonts", package.seeall )

local fonts = {}

function GetAll()
    return fonts
end

function Get( fontName )
    return fonts[ fontName ]
end

local meta = {}
meta.__index = meta

function meta:GetName()
    return self.name
end

-- https://wiki.facepunch.com/gmod/Structures/FontData
function meta:Get( key )
    return self.parameters[ key ]
end

function meta:Set( key, value )
    self.parameters[ key ] = value
    self:Update()
end

do

    local surface_CreateFont = surface.CreateFont
    local math_max = math.max
    local units = units

    function meta:Update()
        local fontData = {}
        local parameters = self.parameters
        for key, value in pairs( parameters ) do
            if ( key == "size" ) then
                fontData[ key ] = math_max( 4, units.Get( value ) )
                continue
            end

            fontData[ key ] = value
        end

        surface_CreateFont( self.name, fontData )
        logger:Debug( "Font created: %s, with size: %s (%spx)", self.name, parameters.size, fontData.size )
    end

end

do

    local setmetatable = setmetatable
    local ArgAssert = ArgAssert

    function Register( fontName, font, size )
        ArgAssert( fontName, 1, "string" )
        ArgAssert( font, 2, "string" )

        local new = setmetatable( {
            ["name"] = fontName,
            ["parameters"] = {
                ["antialias"] = true,
                ["extended"] = true,
                ["weight"] = 500,
                ["font"] = font,
                ["size"] = size
            }
        }, meta )

        fonts[ fontName ] = new
        new:Update()

        return new
    end

end

function UpdateAll()
    logger:Debug( "Updating all fonts..." )
    for _, font in pairs( fonts ) do
        font:Update()
    end
end

hook.Add( "OnScreenSizeChanged", packageName, UpdateAll )