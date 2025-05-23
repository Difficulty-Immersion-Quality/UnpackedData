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
	float2 TexCoords0 TEXCOORD0;
} VertexInput;

typedef struct
{
	float4 ProjectedPosition [[position, invariant]];
	float Depth;
	float2 TexCoords0;
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
	packed_float3 Vector3Parameter_WPO;
	float FloatParameter_Switch_WPO_HeightShimmerWave;
	packed_float3 Vector3Parameter_WPO_Strenght;
	float FloatParameter_DepthBlendDistance;
	packed_float3 _WorldExtents;
	float FloatParameter_UseVT;
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

vertex VertexOutput GustavX_Effects_VFX_OverlayMaterial_AlphaBlend_Unlit_Emissive_SceneColor_Fresnel_DepthBlend_WPO_LateAlpha_Spectre_01_ST_DEPS_vertexMain(constant _CB_MaterialConstants& CB_MaterialConstants [[buffer(MATERIAL_CONSTANTS_BINDING_POINT)]],
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

	//Projected position
	float4 projectedPosition = (PerCamera.g_OffsetViewProjectionMat * float4(worldOffset, 1.0f));

	//Pass projected position to pixel shader
	Out.ProjectedPosition = projectedPosition;

	//View space position
	float3 viewPosition = (float3x3(PerCamera.g_ViewMat[0].xyz, PerCamera.g_ViewMat[1].xyz, PerCamera.g_ViewMat[2].xyz) * worldOffset);

	//Depth
	float depth = viewPosition.z;

	//Pass depth to pixel shader
	Out.Depth = depth;

	Out.TexCoords0 = In.TexCoords0;

	return Out;
}


//[Fragment shader]
#include "Shaders/Metal/CommonHelpers.shdh"
#include "Shaders/Metal/Global/DS_Globals.shdh"
#include "Shaders/Metal/Global/DS_ForwardMaterials.shdh"
#include "Shaders/Metal/VirtualTexturing.shdh"

typedef struct
{
	float4 ProjectedPosition [[position]];
	float Depth;
	float2 TexCoords0;
} PixelInput;

typedef struct
{
} PixelOutput;

static void CalculateMatOpacity(constant _CB_MaterialConstants& CB_MaterialConstants,
	constant _CB_EngineParams& CB_EngineParams,
	constant _PerCamera& PerCamera,
	device GraniteTilesetConstantBuffer* VirtualTexture_TilesetDataBuffer,
	float4 in_0,
	float2 in_1,
	float in_2,
	float2 in_3,
	thread float& out_0,
	sampler _PointMirrorSampler,
	texture2d<float> _LinearDepth,
	texture2d<float> VirtualTexture_Pagetable,
	sampler _DefaultBorderSampler,
	texture2d_array<float> VirtualTexture_Cache0,
	sampler _DefaultWrapSampler,
	texture2d<float> Texture2DParameter_basemap_RGBA,
	texture2d<float> Texture2DParameter_basemap_A)
{
	//DynamicParameterNode {
	//} DynamicParameterNode
	float Local0 = (CB_MaterialConstants.FloatParameter_DepthBlendDistance * in_0.w);
	//DepthDifferenceBlend
	float Local1 = (_LinearDepth.sample(_PointMirrorSampler, in_1).x * PerCamera.g_FarPlane);
	float Local2 = (Local1 - in_2);
	float Local3 = Local2;
	float Local4 = saturate((Local3 / max(Local0, 0.0001f)));
	//~DepthDifferenceBlend

	//OverlayTextureSwitchNode {
	float Local5;
	if(CB_MaterialConstants.FloatParameter_UseVT > 0.0f)
	{
		//VirtualTextureNode {
		float4 Local6;
		float4 Local7 = SampleVirtualTexture(in_3, VirtualTexture_Pagetable, VirtualTexture_Cache0, _DefaultBorderSampler, VirtualTexture_TilesetDataBuffer, CB_EngineParams.VirtualTexture_TilesetDataIndex, CB_EngineParams.VirtualTexture_CB_Texture, 0, Local6);
		//} VirtualTextureNode
		Local5 = Local7.w;
	}
	else
	{
		//Texture2DNode {
		float4 Local8 = Texture2DParameter_basemap_RGBA.sample(_DefaultWrapSampler, in_3);
		//[Local8] Get needed components
		float Local9 = Local8.w;
		//} Texture2DNode
		Local5 = Local9;
	}
	//} OverlayTextureSwitchNode
	//Texture2DNode {
	float4 Local10 = Texture2DParameter_basemap_A.sample(_DefaultWrapSampler, in_3);
	//[Local10] Get needed components
	float Local11 = Local10.w;
	//} Texture2DNode
	float Local12 = (Local5 * Local11);
	float Local13 = smoothstep(0.02f, 0.05f, Local12);
	if ((Local13 - 0.01f) < 0) discard_fragment();
	float Local14 = (Local4 * Local13);
	out_0 = Local14;
}

fragment PixelOutput GustavX_Effects_VFX_OverlayMaterial_AlphaBlend_Unlit_Emissive_SceneColor_Fresnel_DepthBlend_WPO_LateAlpha_Spectre_01_ST_DEPS_fragmentMain(constant _CB_MaterialConstants& CB_MaterialConstants [[buffer(MATERIAL_CONSTANTS_BINDING_POINT)]],
	constant _CB_EngineParams& CB_EngineParams [[buffer(ENGINE_PARAMS_BINDING_POINT)]],
	constant _PerCamera& PerCamera [[buffer(PER_CAMERA_BINDING_POINT)]],
	constant _PerRT& PerRT [[buffer(PER_RT_BINDING_POINT)]],
	device GraniteTilesetConstantBuffer* VirtualTexture_TilesetDataBuffer [[buffer(VT_GRANITE_TILESET_PARAMS_BINDING_POINT)]],
	PixelInput In [[stage_in]],
	sampler _PointMirrorSampler [[sampler(DEFAULT_POINT_MIRROR_SAMPLER_BINDING_POINT)]],
	texture2d<float> _LinearDepth [[texture(LINEARDEPTH_TEXTURE_BINDING_POINT)]],
	texture2d<float> VirtualTexture_Pagetable,
	sampler _DefaultBorderSampler,
	texture2d_array<float> VirtualTexture_Cache0,
	sampler _DefaultWrapSampler [[sampler(DEFAULT_WRAP_SAMPLER_BINDING_POINT)]],
	texture2d<float> Texture2DParameter_basemap_RGBA,
	texture2d<float> Texture2DParameter_basemap_A)
{
	PixelOutput Out;

	float matOpacity;
	//UV position
	float2 Local0 = (In.ProjectedPosition.xy * float2(PerRT.g_RTInvWidth, PerRT.g_RTInvHeight));

	CalculateMatOpacity(CB_MaterialConstants, CB_EngineParams, PerCamera, VirtualTexture_TilesetDataBuffer, CB_MaterialConstants.DynamicParameter, Local0, In.Depth, In.TexCoords0, matOpacity, _PointMirrorSampler, _LinearDepth, VirtualTexture_Pagetable, _DefaultBorderSampler, VirtualTexture_Cache0, _DefaultWrapSampler, Texture2DParameter_basemap_RGBA, Texture2DParameter_basemap_A);
	if ((matOpacity - 0.5f) < 0) discard_fragment();


	return Out;
}
