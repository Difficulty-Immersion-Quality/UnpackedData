#define DISABLE_PROBES

//[Vertex shader]
#include <metal_stdlib>

using namespace metal;

#include "Shaders/Metal/CommonHelpers.shdh"
#include "Shaders/Metal/Global/DS_Globals.shdh"
#include "Shaders/Metal/SkinningHelpers.shdh"

typedef struct
{
	float3 Position SV_POSITION0;
	float4 VertexColor COLOR0;
	float2 UnpackedUVs TEXCOORD4;
	float2 TexCoords0 TEXCOORD0;
	float4 LocalQTangent NORMAL0;
} VertexInput;

typedef struct
{
	float4 ProjectedPosition [[position]];
	float2 TexCoords0;
	float3 LocalPosition;
	float3 LocalNormal;
	float3 WorldNormal;
	float3 WorldBinormal;
	float3 WorldTangent;
	float3 WorldOffset;
	float Depth;
} VertexOutput;

struct _CB_EngineParams
{
	float4x4 WorldOffsetMatrix;
	float4 VirtualTexture_CB_Texture[2];
	uint TransformedVerticesOffset;
	uint VirtualTexture_TilesetDataIndex;
};
struct _CB_MaterialConstants
{
	float4 DynamicParameter;
	float4 Vector4Parameter_Color;
	packed_float3 Vector3Parameter_WPO;
	float FloatParameter_Switch_WPO_HeightShimmerWave;
	packed_float3 Vector3Parameter_WPO_Strenght;
	float FloatParameter_SceneColorBrightness;
	packed_float3 _WorldExtents;
	float FloatParameter_BaseColorBlend;
	packed_float3 Vector3Parameter_SubtractiveBonePosition_Offset;
	float FloatParameter_Triplanar_Texture_UVTiling;
	packed_float3 Vector3Parameter_SubtractiveBonePosition;
	float FloatParameter_Triplanar_Texture_EXP;
	float2 Vector2Parameter_Triplanar_Texture_PanningSpeed;
	float FloatParameter_UseVT;
	float FloatParameter_Fresnel_Power;
	float FloatParameter_Switch_DynX_Fresnel_Power;
	float FloatParameter_DepthBlendDistance;
	float FloatParameter_SubtractiveMaskRadius;
	float FloatParameter_SubtractiveMaskIntensity;
	float FloatParameter_Switch_SubtractiveMask;
	float FloatParameter_PreRamp_Intensity;
	float FloatParameter_PostRamp_Intensity;
	float FloatParameter_Switch_ColorRamp;
};
static void CalculateMatWorldPositionOffset(constant _CB_MaterialConstants& CB_MaterialConstants,
	constant _PerFrame& PerFrame,
	float4 in_0,
	float3 in_1,
	float4x4 in_2,
	float3 in_3,
	float3 in_4,
	float4 in_5,
	thread float3& out_0,
	sampler _PointWrapSampler,
	texture2d<float> Texture2DParameter_VertexColor_MSK)
{
	//DynamicParameterNode {
	//} DynamicParameterNode
	float3 Local0 = mix(CB_MaterialConstants.Vector3Parameter_WPO, float3(0.0f, 0.0f, 0.0f), float3(in_0.y, in_0.y, in_0.y));
	//LocalPosition {
	//} LocalPosition
	float Local1 = in_1.y;
	float Local2 = (CB_MaterialConstants._WorldExtents.y * 0.02f);
	float Local3 = (Local1 / Local2);
	float Local4 = (PerFrame.g_CurrentTime + Local3);
	// TriangleWaveNode {
	//TriangleWave
	float Local5 = abs(((fract((Local4 + 0.5f)) * 2.0f) - 1.0f));
	//Smooth TriangleWave
	float Local6 = ((Local5 * Local5) * (3.0f - (2.0f * Local5)));
	// } TriangleWaveNode
	float3 Local7 = (CB_MaterialConstants.Vector3Parameter_WPO_Strenght * Local6);
	//TransformDirectionNode {
	float3 Local8 = (float3x3(in_2[0].xyz, in_2[1].xyz, in_2[2].xyz) * Local7);
	//} TransformDirectionNode
	float3 Local9 = mix(float3(0.0f, 0.0f, 0.0f), Local8, float3(CB_MaterialConstants.FloatParameter_Switch_WPO_HeightShimmerWave, CB_MaterialConstants.FloatParameter_Switch_WPO_HeightShimmerWave, CB_MaterialConstants.FloatParameter_Switch_WPO_HeightShimmerWave));
	float3 Local10 = (Local0 + Local9);
	//ObjectWorldPositionNode {
	//] ObjectWorldPositionNode
	//WorldPositionNode {
	//} WorldPositionNode
	float3 Local11 = (in_3 - in_4);
	float Local12 = fmod(in_5.y, 0.0625f);
	float Local13 = (16.0f * Local12);
	float Local14 = (16.0f * in_5.y);
	float Local15 = floor(Local14);
	float Local16 = (0.0625f * Local15);
	float2 Local17 = float2(Local13, Local16);
	//Texture2DNode {
	float4 Local18 = Texture2DParameter_VertexColor_MSK.sample(_PointWrapSampler, Local17,  level(0.0f));
	//[Local18] Get needed components
	float Local19 = Local18.y;
	//} Texture2DNode
	float Local20 = step(0.01f, Local19);
	float3 Local21 = (Local11 * Local20);
	float3 Local22 = (Local10 + Local21);
	out_0 = Local22;
}

vertex VertexOutput GustavX_Effects_VFX_OverlayMaterial_AlphaBlend_Unlit_Emissive_SceneColor_Fresnel_DepthBlend_WPO_LateAlpha_Spectre_01_ST_BAKE_vertexMain(constant _CB_MaterialConstants& CB_MaterialConstants [[buffer(MATERIAL_CONSTANTS_BINDING_POINT)]],
	constant _CB_EngineParams& CB_EngineParams [[buffer(ENGINE_PARAMS_BINDING_POINT)]],
	constant _PerFrame& PerFrame [[buffer(PER_FRAME_BINDING_POINT)]],
	constant _PerCamera& PerCamera [[buffer(PER_CAMERA_BINDING_POINT)]],
	constant const uint8_t* TransformedVertices [[buffer(TRANS_VERT_BINDING_POINT)]],
	uint VertexID [[vertex_id]],
	VertexInput In [[stage_in]],
	sampler _PointWrapSampler,
	texture2d<float> Texture2DParameter_VertexColor_MSK)
{
	VertexOutput Out;

	float3 matWorldPositionOffset;
	//Object World Offset
	float3 objectWorldOffset = CB_EngineParams.WorldOffsetMatrix[3].xyz;

	//Object World Position
	float3 objectWorldPosition = (objectWorldOffset + PerCamera.g_CameraWorldPos.xyz);

	float3 localPositionStatic = In.Position;
	if(CB_EngineParams.TransformedVerticesOffset > 0)
	{
		//Skinned vertex
		localPositionStatic = GetSkinnedPosition(VertexID, CB_EngineParams.TransformedVerticesOffset, TransformedVertices);
	}
	//World space offset
	float3 worldOffset = (CB_EngineParams.WorldOffsetMatrix * float4(localPositionStatic, 1.0f)).xyz;

	//World Position
	float3 worldPosition = (worldOffset + PerCamera.g_CameraWorldPos.xyz);

	CalculateMatWorldPositionOffset(CB_MaterialConstants, PerFrame, CB_MaterialConstants.DynamicParameter, In.Position.xyz, CB_EngineParams.WorldOffsetMatrix, objectWorldPosition, worldPosition.xyz, In.VertexColor, matWorldPositionOffset, _PointWrapSampler, Texture2DParameter_VertexColor_MSK);
	worldOffset = (worldOffset + matWorldPositionOffset);

	//UVs as projected position {
	//Flip UV.y coordinate so mesh won't be flipped
	//Use extra UV set for unpacked with Houdini UV islands
	float2 uv_coordinates = In.UnpackedUVs;
	uv_coordinates = float2(uv_coordinates.x, (1.0f - uv_coordinates.y));

	uv_coordinates = fma(uv_coordinates, float2(2.0f, 2.0f), float2(-1.0f, -1.0f));
	float4 uv_projected = float4(uv_coordinates, 0.0f, 1.0f);
	float4 projectedPosition = uv_projected;
	//} UVs as projected position

	//Pass projected position to pixel shader
	Out.ProjectedPosition = projectedPosition;

	Out.TexCoords0 = In.TexCoords0;
	//Pass local position to pixel shader
	Out.LocalPosition = In.Position;

	//Compute localTangentFrame tangent frame
	float3x3 localTangentFrame = GetTangentFrame(In.LocalQTangent);

	float3 localNormal = localTangentFrame[2];

	//Pass Local Normal to PS
	Out.LocalNormal = localNormal;

	float4 transformedQTangent = In.LocalQTangent;
	if(CB_EngineParams.TransformedVerticesOffset > 0)
	{
		//Skinned QTangent
		transformedQTangent = GetSkinnedQTangent(VertexID, CB_EngineParams.TransformedVerticesOffset, TransformedVertices);
	}
	//Compute transformedTangentFrame tangent frame
	float3x3 transformedTangentFrame = GetTangentFrame(transformedQTangent);

	float3 transformedNormal = transformedTangentFrame[2];

	//World space Normal
	float3 worldNormal = (float3x3(CB_EngineParams.WorldOffsetMatrix[0].xyz, CB_EngineParams.WorldOffsetMatrix[1].xyz, CB_EngineParams.WorldOffsetMatrix[2].xyz) * transformedNormal);

	//Normalize World Normal
	float3 worldNormalNormalized = normalize(worldNormal);

	Out.WorldNormal = worldNormalNormalized;

	float3 transformedBinormal = transformedTangentFrame[1];

	//World space Binormal
	float3 worldBinormal = (float3x3(CB_EngineParams.WorldOffsetMatrix[0].xyz, CB_EngineParams.WorldOffsetMatrix[1].xyz, CB_EngineParams.WorldOffsetMatrix[2].xyz) * transformedBinormal);

	//Normalize World Binormal
	float3 worldBinormalNormalized = normalize(worldBinormal);

	Out.WorldBinormal = worldBinormalNormalized;

	float3 transformedTangent = transformedTangentFrame[0];

	//World space Tangent
	float3 worldTangent = (float3x3(CB_EngineParams.WorldOffsetMatrix[0].xyz, CB_EngineParams.WorldOffsetMatrix[1].xyz, CB_EngineParams.WorldOffsetMatrix[2].xyz) * transformedTangent);

	//Normalize World Tangent
	float3 worldTangentNormalized = normalize(worldTangent);

	Out.WorldTangent = worldTangentNormalized;

	//Pass world offset to pixel shader
	Out.WorldOffset = worldOffset;

	//View space position
	float3 viewPosition = (float3x3(PerCamera.g_ViewMat[0].xyz, PerCamera.g_ViewMat[1].xyz, PerCamera.g_ViewMat[2].xyz) * worldOffset);

	//Depth
	float depth = viewPosition.z;

	//Pass depth to pixel shader
	Out.Depth = depth;


	return Out;
}


//[Fragment shader]
#include "Shaders/Metal/CommonHelpers.shdh"
#include "Shaders/Metal/Global/DS_Globals.shdh"
#include "Shaders/Metal/Global/DS_ForwardMaterials.shdh"
#include "Shaders/Metal/VirtualTexturing.shdh"
#include "Shaders/Metal/PBR.shdh"

typedef struct
{
	float4 ProjectedPosition [[position]];
	float2 TexCoords0;
	float3 LocalPosition;
	float3 LocalNormal;
	float3 WorldNormal;
	float3 WorldBinormal;
	float3 WorldTangent;
	float3 WorldOffset;
	float Depth;
} PixelInput;

typedef struct
{
	float4 Color0 [[color(0)]];
	float4 Color1 [[color(1)]];
	float4 Color2 [[color(2)]];
	float4 Color3 [[color(3)]];
} PixelOutput;

static void CalculateMatEmissiveColor(constant _CB_MaterialConstants& CB_MaterialConstants,
	constant _CB_EngineParams& CB_EngineParams,
	constant _PerFrame& PerFrame,
	constant _PerCamera& PerCamera,
	device GraniteTilesetConstantBuffer* VirtualTexture_TilesetDataBuffer,
	float2 in_0,
	float2 in_1,
	float3 in_2,
	float3 in_3,
	float4 in_4,
	float3 in_5,
	float in_6,
	thread float3& out_0,
	thread float4& VTFeedback,
	sampler _PointMirrorSampler,
	texture2d<float> _Scene,
	sampler _DefaultWrapSampler,
	texture2d<float> Texture2DParameter_basecolor,
	texture2d<float> Texture2DParameter_Triplanar_Texture_Map,
	texture2d<float> VirtualTexture_Pagetable,
	sampler _DefaultBorderSampler,
	texture2d_array<float> VirtualTexture_Cache1,
	texture2d<float> Texture2DParameter_NM,
	texture2d<float> _LinearDepth,
	sampler _DefaultClampSampler,
	texture2d<float> Texture2DParameter_ColorRamp_Texture_DefaultClampSampler)
{
	float3 Local0 = (_Scene.sample(_PointMirrorSampler, in_0).xyz * CB_MaterialConstants.FloatParameter_SceneColorBrightness);
	//Texture2DNode {
	float4 Local1 = Texture2DParameter_basecolor.sample(_DefaultWrapSampler, in_1);
	//[Local1] Get needed components
	float3 Local2 = Local1.xyz;
	float Local3 = Local1.w;
	//} Texture2DNode
	float3 Local4 = mix(Local0, Local2, float3(CB_MaterialConstants.FloatParameter_BaseColorBlend, CB_MaterialConstants.FloatParameter_BaseColorBlend, CB_MaterialConstants.FloatParameter_BaseColorBlend));
	float3 Local5 = CB_MaterialConstants.Vector4Parameter_Color.xyz;
	//LocalPosition {
	//} LocalPosition
	float3 Local6 = (in_2 * CB_MaterialConstants.FloatParameter_Triplanar_Texture_UVTiling);
	float2 Local7 = Local6.xz;
	float Local8 = (PerFrame.g_CurrentTime * 1.0f);
	float2 Local9 = (Local8 * CB_MaterialConstants.Vector2Parameter_Triplanar_Texture_PanningSpeed);
	float2 Local10 = (Local7 + Local9);
	//Texture2DNode {
	float4 Local11 = Texture2DParameter_Triplanar_Texture_Map.sample(_DefaultWrapSampler, Local10);
	//[Local11] Get needed components
	float Local12 = Local11.x;
	//} Texture2DNode
	float2 Local13 = Local6.xy;
	float2 Local14 = (Local13 + Local9);
	//Texture2DNode {
	float4 Local15 = Texture2DParameter_Triplanar_Texture_Map.sample(_DefaultWrapSampler, Local14);
	//[Local15] Get needed components
	float Local16 = Local15.x;
	//} Texture2DNode
	//LocalNormal {
	//} LocalNormal
	//AbsNode {
	float3 Local17 = abs(in_3);
	//} AbsNode
	float Local18 = Local17.z;
	float Local19 = mix(Local12, Local16, Local18);
	float2 Local20 = Local6.zy;
	float2 Local21 = (Local20 + Local9);
	//Texture2DNode {
	float4 Local22 = Texture2DParameter_Triplanar_Texture_Map.sample(_DefaultWrapSampler, Local21);
	//[Local22] Get needed components
	float Local23 = Local22.x;
	//} Texture2DNode
	//AbsNode {
	float3 Local24 = abs(in_3);
	//} AbsNode
	float Local25 = Local24.x;
	float Local26 = mix(Local19, Local23, Local25);
	float Local27 = pow(Local26, CB_MaterialConstants.FloatParameter_Triplanar_Texture_EXP);
	//OverlayTextureSwitchNode {
	float3 Local28;
	if(CB_MaterialConstants.FloatParameter_UseVT > 0.0f)
	{
		//VirtualTextureNode {
		float4 Local29 = SampleVirtualTexture(in_1, VirtualTexture_Pagetable, VirtualTexture_Cache1, _DefaultBorderSampler, VirtualTexture_TilesetDataBuffer, CB_EngineParams.VirtualTexture_TilesetDataIndex, CB_EngineParams.VirtualTexture_CB_Texture, 1, VTFeedback);
		//[Local29] Convert normalmaps to tangent space vectors
		Local29.xyzw = Local29.wzyx;
		Local29.xyz = ((Local29.xyz * 2.0f) - 1.0f);
		Local29.z = -(Local29.z);
		Local29.xyz = normalize(Local29.xyz);
		//} VirtualTextureNode
		Local28 = Local29.xyz;
	}
	else
	{
		//Texture2DNode {
		float4 Local30 = Texture2DParameter_NM.sample(_DefaultWrapSampler, in_1);
		//[Local30] Convert normalmaps to tangent space vectors
		Local30.xyzw = Local30.wzyx;
		Local30.xyz = ((Local30.xyz * 2.0f) - 1.0f);
		Local30.z = -(Local30.z);
		Local30.xyz = normalize(Local30.xyz);
		//[Local30] Get needed components
		float3 Local31 = Local30.xyz;
		float Local32 = Local30.w;
		//} Texture2DNode
		Local28 = Local31.xyz;
	}
	//} OverlayTextureSwitchNode
	//DynamicParameterNode {
	//} DynamicParameterNode
	float Local33 = mix(CB_MaterialConstants.FloatParameter_Fresnel_Power, in_4.x, CB_MaterialConstants.FloatParameter_Switch_DynX_Fresnel_Power);
	//FresnelNode {
	float Local34 = pow((1.0f - saturate(dot(Local28, in_5))), Local33);
	//} FresnelNode
	float Local35 = (Local27 * Local34);
	//DynamicParameterNode {
	//} DynamicParameterNode
	float Local36 = (CB_MaterialConstants.FloatParameter_DepthBlendDistance * in_4.w);
	//DepthDifferenceBlend
	float Local37 = (_LinearDepth.sample(_PointMirrorSampler, in_0).x * PerCamera.g_FarPlane);
	float Local38 = (Local37 - in_6);
	float Local39 = Local38;
	float Local40 = saturate((Local39 / max(Local36, 0.0001f)));
	//~DepthDifferenceBlend

	float3 Local41 = (CB_MaterialConstants.Vector3Parameter_SubtractiveBonePosition_Offset + CB_MaterialConstants.Vector3Parameter_SubtractiveBonePosition);
	float3 Local42 = (Local41 + float3(CB_MaterialConstants.FloatParameter_SubtractiveMaskRadius, CB_MaterialConstants.FloatParameter_SubtractiveMaskRadius, CB_MaterialConstants.FloatParameter_SubtractiveMaskRadius));
	float3 Local43 = (Local41 - Local42);
	//DotNode {
	float Local44 = dot(Local43, Local43);
	//} DotNode
	float Local45 = sqrt(Local44);
	//LocalPosition {
	//} LocalPosition
	float3 Local46 = (Local41 - in_2);
	//DotNode {
	float Local47 = dot(Local46, Local46);
	//} DotNode
	float Local48 = sqrt(Local47);
	float Local49 = (Local45 - Local48);
	float Local50 = (Local49 / Local45);
	float Local51 = clamp(Local50, 0.0f, 1.0f);
	float Local52 = (1.0f - Local51);
	float Local53 = pow(Local52, CB_MaterialConstants.FloatParameter_SubtractiveMaskIntensity);
	float Local54 = mix(1.0f, Local53, CB_MaterialConstants.FloatParameter_Switch_SubtractiveMask);
	float Local55 = (Local40 * Local54);
	float Local56 = (Local35 * Local55);
	float Local57 = (Local56 * CB_MaterialConstants.FloatParameter_PreRamp_Intensity);
	//ColorRampTextureNode {
	float4 Local58 = Texture2DParameter_ColorRamp_Texture_DefaultClampSampler.sample(_DefaultClampSampler, float2(Local57, 0.0f),  level(0.0f));
	float3 Local59 = Local58.xyz;
	//} ColorRampTextureNode
	//DynamicParameterNode {
	//} DynamicParameterNode
	float3 Local60 = (Local59 * in_4.z);
	float3 Local61 = (Local60 * CB_MaterialConstants.FloatParameter_PostRamp_Intensity);
	float3 Local62 = mix(float3(Local35, Local35, Local35), Local61, float3(CB_MaterialConstants.FloatParameter_Switch_ColorRamp, CB_MaterialConstants.FloatParameter_Switch_ColorRamp, CB_MaterialConstants.FloatParameter_Switch_ColorRamp));
	float Local63 = CB_MaterialConstants.Vector4Parameter_Color.w;
	float Local64 = (Local63 * Local3);
	float Local65 = (Local64 * Local40);
	float Local66 = (Local65 * Local55);
	float3 Local67 = mix(float3(0.0f, 0.0f, 0.0f), Local62, float3(Local66, Local66, Local66));
	float3 Local68 = (Local5 * Local67);
	float3 Local69 = (Local4 + Local68);
	out_0 = Local69;
}

fragment PixelOutput GustavX_Effects_VFX_OverlayMaterial_AlphaBlend_Unlit_Emissive_SceneColor_Fresnel_DepthBlend_WPO_LateAlpha_Spectre_01_ST_BAKE_fragmentMain(constant _CB_MaterialConstants& CB_MaterialConstants [[buffer(MATERIAL_CONSTANTS_BINDING_POINT)]],
	constant _CB_EngineParams& CB_EngineParams [[buffer(ENGINE_PARAMS_BINDING_POINT)]],
	constant _PerFrame& PerFrame [[buffer(PER_FRAME_BINDING_POINT)]],
	constant _PerCamera& PerCamera [[buffer(PER_CAMERA_BINDING_POINT)]],
	constant _PerRT& PerRT [[buffer(PER_RT_BINDING_POINT)]],
	device GraniteTilesetConstantBuffer* VirtualTexture_TilesetDataBuffer [[buffer(VT_GRANITE_TILESET_PARAMS_BINDING_POINT)]],
	PixelInput In [[stage_in]],
	sampler _PointMirrorSampler [[sampler(DEFAULT_POINT_MIRROR_SAMPLER_BINDING_POINT)]],
	texture2d<float> _Scene [[texture(SCENE_TEXTURE_BINDING_POINT)]],
	sampler _DefaultWrapSampler [[sampler(DEFAULT_WRAP_SAMPLER_BINDING_POINT)]],
	texture2d<float> Texture2DParameter_basecolor,
	texture2d<float> Texture2DParameter_Triplanar_Texture_Map,
	texture2d<float> VirtualTexture_Pagetable,
	sampler _DefaultBorderSampler,
	texture2d_array<float> VirtualTexture_Cache1,
	texture2d<float> Texture2DParameter_NM,
	texture2d<float> _LinearDepth [[texture(LINEARDEPTH_TEXTURE_BINDING_POINT)]],
	sampler _DefaultClampSampler [[sampler(DEFAULT_CLAMP_SAMPLER_BINDING_POINT)]],
	texture2d<float> Texture2DParameter_ColorRamp_Texture_DefaultClampSampler)
{
	PixelOutput Out;

	float4 VTFeedback = float4(1.0f, 1.0f, 1.0f, 1.0f);

	float4 svMatBaseColor;
	svMatBaseColor = float4(float3(0.0f, 0.0f, 0.0f), 1.0f);
	float3 matEmissiveColor;
	//UV position
	float2 Local0 = (In.ProjectedPosition.xy * float2(PerRT.g_RTInvWidth, PerRT.g_RTInvHeight));

	//Normalize Local Normal
	float3 localNormalNormalized = normalize(In.LocalNormal);

	float3x3 NBT_WS = float3x3(float3(In.WorldTangent.x, In.WorldNormal.x, In.WorldBinormal.x), float3(In.WorldTangent.y, In.WorldNormal.y, In.WorldBinormal.y), float3(In.WorldTangent.z, In.WorldNormal.z, In.WorldBinormal.z));

	//Normalized world space view vector
	float3 worldViewNormalized = normalize(-(In.WorldOffset));

	//Calculate tangent space view vector
	float3 tangentView = normalize((NBT_WS * worldViewNormalized));

	CalculateMatEmissiveColor(CB_MaterialConstants, CB_EngineParams, PerFrame, PerCamera, VirtualTexture_TilesetDataBuffer, Local0, In.TexCoords0, In.LocalPosition.xyz, localNormalNormalized, CB_MaterialConstants.DynamicParameter, tangentView, In.Depth, matEmissiveColor, VTFeedback, _PointMirrorSampler, _Scene, _DefaultWrapSampler, Texture2DParameter_basecolor, Texture2DParameter_Triplanar_Texture_Map, VirtualTexture_Pagetable, _DefaultBorderSampler, VirtualTexture_Cache1, Texture2DParameter_NM, _LinearDepth, _DefaultClampSampler, Texture2DParameter_ColorRamp_Texture_DefaultClampSampler);
	float4 physicalValue;
	physicalValue = float4(0.0f, 0.5f, 1.0f, 0.5f);
	float4 outNormal;
	outNormal = float4(float3(0.0f, 1.0f, 0.0f), 0.0f);
	outNormal.z = -(outNormal.z);
	outNormal = fma(outNormal, float4(0.5f, 0.5f, 0.5f, 0.5f), float4(0.5f, 0.5f, 0.5f, 0.0f));
	outNormal = float4(outNormal.w, outNormal.z, outNormal.y, outNormal.x);
	Out.Color0 = outNormal;
	//Baked base color output
	Out.Color1 = pow(svMatBaseColor, float4(0.4545454f, 0.4545454f, 0.4545454f, 1.0f));
	Out.Color2 = physicalValue;
	Out.Color3 = float4(matEmissiveColor, 1.0f);

	return Out;
}
