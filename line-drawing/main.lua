----------------------------------------------------------------
-- Copyright (c) 2010-2011 Zipline Games, Inc. 
-- All Rights Reserved. 
-- http://getmoai.com
----------------------------------------------------------------

MOAISim.openWindow ( "test", 520, 680 )

viewport = MOAIViewport.new ()
viewport:setSize ( 520, 680 )
viewport:setScale ( 520, 680 )

layer = MOAILayer.new ()
layer:setViewport ( viewport )
MOAISim.pushRenderPass ( layer )

camera = MOAICamera.new ()
camera:setFieldOfView ( 65.0 )
camera:setLoc ( 0, 0, camera:getFocalLength ( 320 ))
layer:setCamera ( camera )


program = MOAIShaderProgram.new ()

program:setVertexAttribute ( 1, 'position' )
program:setVertexAttribute ( 2, 'prevPosition' )
program:setVertexAttribute ( 3, 'nextPosition' )
program:setVertexAttribute ( 4, 'side' )

--program:reserveUniforms ( 1 )
--program:declareUniform ( 1, 'maskColor', MOAIShaderProgram.UNIFORM_VECTOR_F4 )

program:load ( MOAIFileSystem.loadFile ( 'shader.vsh' ), MOAIFileSystem.loadFile ( 'shader.fsh' ))

shader = MOAIShader.new ()
shader:setProgram ( program )
--shader:setAttrLink ( 1, color, MOAIColor.COLOR_TRAIT )

program:reserveUniforms ( 1 )
program:declareUniform ( 1, 'transform', MOAIShaderProgram.UNIFORM_MATRIX_F4 )

program:reserveGlobals ( 1 )
program:setGlobal ( 1, 1, MOAIShaderProgram.GLOBAL_WORLD_VIEW_PROJ )

local vertexFormat = MOAIVertexFormat.new ()
vertexFormat:declareCoord ( 1, MOAIVertexFormat.GL_FLOAT, 3 ) -- current
vertexFormat:declareAttribute ( 2, MOAIVertexFormat.GL_FLOAT, 3 ) -- previous
vertexFormat:declareAttribute ( 3, MOAIVertexFormat.GL_FLOAT, 3 ) -- next
vertexFormat:declareAttribute ( 4, MOAIVertexFormat.GL_FLOAT, 1 )

local writeVertex = function ( stream, verts, index, side, snap, closed )

	local v0 = verts [ index ]

	stream:writeFloat ( v0.x, v0.y, v0.z )

	local p, n

	if side == 0.0 then

			if index == 1 then

				p = verts [ index + 1 ]
				n = verts [ 1 ]

			elseif index == #verts then

				p = verts [ index ]
				n = verts [ index - 1 ]
			else

				p = verts [ index + 1 ]
				n = verts [ index - 1 ]
			end
	else

		if index == 1 then

			p = verts [ 1 ]
			n = verts [ index + 1 ]

		elseif index == #verts then

			p = verts [ index - 1 ]
			n = verts [ index ]
		else
			
			p = verts [ index - 1 ]
			n = verts [ index + 1 ]
		end
	end

	stream:writeFloat ( p.x, p.y, p.z )
	stream:writeFloat ( n.x, n.y, n.z )
	stream:writeFloat ( snap )
end

local pushVert = function ( verts, x, y, z )

	table.insert ( verts, { x = x, y = y, z = z })
end

local vtxStream = MOAIMemStream.new ()

local verts = {}

--[[
pushVert ( verts, -100, 100, 0 )
pushVert ( verts, 100, 100, 0 )
pushVert ( verts, 100, -100, 0 )
pushVert ( verts, -100, -100, 0 )
pushVert ( verts, -100, 100, 0 )
]]--

pushVert ( verts, 0, 100, 0 )
pushVert ( verts, 0, 0, 0 )

pushVert ( verts, 100, 0, 0 )
pushVert ( verts, 100, -100, 0 )
pushVert ( verts, -100, -100, 0 )

pushVert ( verts, -100, 100, 0 )
pushVert ( verts, 0, 0, 0 )
pushVert ( verts, -100, 100, 0 )

--pushVert ( verts, 100, 0, 0 )
--pushVert ( verts, -114.315, 0, 0 )
--pushVert ( verts, -100.0, 0, 0 )
--pushVert ( verts, -50, 0, 0 )

local facetCount = 4

for i = 1, #verts - 1 do

	local a = i
	local b = i + 1

	writeVertex ( vtxStream, verts, a, 0, 0 )
	writeVertex ( vtxStream, verts, b, 1, 0 )
	writeVertex ( vtxStream, verts, a, 1, 1 )

	writeVertex ( vtxStream, verts, a, 0, 0 )
	writeVertex ( vtxStream, verts, b, 0, 1 )
	writeVertex ( vtxStream, verts, b, 1, 0 )

	if i < #verts - 1 then 

		for j = 1, facetCount do
		
			local rt0 = ( j - 1 ) / facetCount
			local rt1 = j / facetCount

			local lt0 = 1.0 - rt0
			local lt1 = 1.0 - rt1

			writeVertex ( vtxStream, verts, b, 0, lt0 )
			writeVertex ( vtxStream, verts, b, 1, rt1 )
			writeVertex ( vtxStream, verts, b, 1, rt0 )

			writeVertex ( vtxStream, verts, b, 0, lt0 )
			writeVertex ( vtxStream, verts, b, 0, lt1 )
			writeVertex ( vtxStream, verts, b, 1, rt1 )
		end
	end
end

vtxStream:seek ( 0 * vertexFormat:getVertexSize ())

local vbo = MOAIVertexBuffer.new ()
vbo:copyFromStream ( vtxStream )

local mesh = MOAIMesh.new ()

mesh:setVertexBuffer ( vbo, vertexFormat )

mesh:setTotalElements ( vbo:countElements ( vertexFormat ))
--mesh:setTotalElements ( 6 )
mesh:setBounds ( vbo:computeBounds ( vertexFormat ))

mesh:setPrimType ( MOAIMesh.GL_TRIANGLES )
mesh:setShader ( shader )

prop = MOAIProp.new ()
prop:setDeck ( mesh )
--prop:setRot ( 270, 270, 0 )
prop:moveRot ( 360, 360, 0, 12 )
--prop:setCullMode ( MOAIGraphicsProp.CULL_BACK )
layer:insertProp ( prop )