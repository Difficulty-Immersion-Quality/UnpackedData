#define DISABLE_PROBES

//[Vertex shader]
#include <metal_stdlib>

using namespace metal;

#include "Shaders/Metal/CommonHelpers.shdh"
#include "Shaders/Metal/Global/DS_Globals.shdh"

typedef struct
{
	float4 InstanceDynamicParameter COLOR5;
	float3 Position SV_POSITION0;
	float4 InstanceMatrix1 COLOR1;
	float4 InstanceMatrix2 COLOR2;
	float4 InstanceMatrix3 COLOR3;
	float4 VertexColor COLOR0;
	float2 TexCoords0 TEXCOORD0;
	float4 LocalQTangent NORMAL0;
} VertexInput;

typedef struct
{
	float4 ProjectedPosition [[position, invariant]];
	float2 TexCoords0;
	float3 LocalPosition;
	float3 LocalNormal;
	float4 InstanceDynamicParameter;
	float3 WorldNormal;
	float3 WorldBinormal;
	float3 WorldTangent;
	float3 WorldOffset;
	float Depth;
} VertexOutput;

struct _CB_EngineParams
{
	float4 VirtualTexture_CB_Texture[2];
	packed_float3 WorldOffset;
	uint VirtualTexture_TilesetDataIndex;
};
struct _CB_MaterialConstants
{
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

vertex VertexOutput GustavX_Effects_VFX_OverlayMaterial_AlphaBlend_Unlit_Emissive_SceneColor_Fresnel_DepthBlend_WPO_LateAlpha_Spectre_01_STI_EMI_vertexMain(constant _CB_MaterialConstants& CB_MaterialConstants [[buffer(MATERIAL_CONSTANTS_BINDING_POINT)]],
	constant _CB_EngineParams& CB_EngineParams [[buffer(ENGINE_PARAMS_BINDING_POINT)]],
	constant _PerFrame& PerFrame [[buffer(PER_FRAME_BINDING_POINT)]],
	constant _PerCamera& PerCamera [[buffer(PER_CAMERA_BINDING_POINT)]],
	VertexInput In [[stage_in]],
	sampler _PointWrapSampler,
	texture2d<float> Texture2DParameter_VertexColor_MSK)
{
	VertexOutput Out;

	float3 matWorldPositionOffset;
	//Create Instance Dynamic Parameter
	//Create Instance WorldOffset Matrix
	float4x4 noBillboardWorldOffsetMatrix = float4x4(float4(In.InstanceMatrix1.x, In.InstanceMatrix2.x, In.InstanceMatrix3.x, 0.0f), float4(In.InstanceMatrix1.y, In.InstanceMatrix2.y, In.InstanceMatrix3.y, 0.0f), float4(In.InstanceMatrix1.z, In.InstanceMatrix2.z, In.InstanceMatrix3.z, 0.0f), float4(In.InstanceMatrix1.w, In.InstanceMatrix2.w, In.InstanceMatrix3.w, 1.0f));
	noBillboardWorldOffsetMatrix[3].xyz = (noBillboardWorldOffsetMatrix[3].xyz + CB_EngineParams.WorldOffset);

	//Object World Offset
	float3 objectWorldOffset = noBillboardWorldOffsetMatrix[3].xyz;

	//Object World Position
	float3 objectWorldPosition = (objectWorldOffset + PerCamera.g_CameraWorldPos.xyz);

	float3 localPositionStatic = In.Position;
	//World space offset
	float3 worldOffset = (noBillboardWorldOffsetMatrix * float4(localPositionStatic, 1.0f)).xyz;

	//World Position
	float3 worldPosition = (worldOffset + PerCamera.g_CameraWorldPos.xyz);

	CalculateMatWorldPositionOffset(CB_MaterialConstants, PerFrame, In.InstanceDynamicParameter, In.Position.xyz, noBillboardWorldOffsetMatrix, objectWorldPosition, worldPosition.xyz, In.VertexColor, matWorldPositionOffset, _PointWrapSampler, Texture2DParameter_VertexColor_MSK);
	worldOffset = (worldOffset + matWorldPositionOffset);

	//Projected position
	float4 projectedPosition = (PerCamera.g_OffsetViewProjectionMat * float4(worldOffset, 1.0f));

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

	Out.InstanceDynamicParameter = In.InstanceDynamicParameter;
	//World space Normal
	float3 worldNormal = (float3x3(noBillboardWorldOffsetMatrix[0].xyz, noBillboardWorldOffsetMatrix[1].xyz, noBillboardWorldOffsetMatrix[2].xyz) * localNormal);

	//Normalize World Normal
	float3 worldNormalNormalized = normalize(worldNormal);

	Out.WorldNormal = worldNormalNormalized;

	float3 localBinormal = localTangentFrame[1];

	//World space Binormal
	float3 worldBinormal = (float3x3(noBillboardWorldOffsetMatrix[0].xyz, noBillboardWorldOffsetMatrix[1].xyz, noBillboardWorldOffsetMatrix[2].xyz) * localBinormal);

	//Normalize World Binormal
	float3 worldBinormalNormalized = normalize(worldBinormal);

	Out.WorldBinormal = worldBinormalNormalized;

	float3 localTangent = localTangentFrame[0];

	//World space Tangent
	float3 worldTangent = (float3x3(noBillboardWorldOffsetMatrix[0].xyz, noBillboardWorldOffsetMatrix[1].xyz, noBillboardWorldOffsetMatrix[2].xyz) * localTangent);

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

typedef struct
{
	float4 ProjectedPosition [[position]];
	float2 TexCoords0;
	float3 LocalPosition;
	float3 LocalNormal;
	float4 InstanceDynamicParameter;
	float3 WorldNormal;
	float3 WorldBinormal;
	float3 WorldTangent;
	float3 WorldOffset;
	float Depth;
} PixelInput;

typedef struct
{
	float4 Color0 [[color(0)]];
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
		float4 Local29;
		float4 Local30 = SampleVirtualTexture(in_1, VirtualTexture_Pagetable, VirtualTexture_Cache1, _DefaultBorderSampler, VirtualTexture_TilesetDataBuffer, CB_EngineParams.VirtualTexture_TilesetDataIndex, CB_EngineParams.VirtualTexture_CB_Texture, 1, Local29);
		//[Local30] Convert normalmaps to tangent space vectors
		Local30.xyzw = Local30.wzyx;
		Local30.xyz = ((Local30.xyz * 2.0f) - 1.0f);
		Local30.z = -(Local30.z);
		Local30.xyz = normalize(Local30.xyz);
		//} VirtualTextureNode
		Local28 = Local30.xyz;
	}
	else
	{
		//Texture2DNode {
		float4 Local31 = Texture2DParameter_NM.sample(_DefaultWrapSampler, in_1);
		//[Local31] Convert normalmaps to tangent space vectors
		Local31.xyzw = Local31.wzyx;
		Local31.xyz = ((Local31.xyz * 2.0f) - 1.0f);
		Local31.z = -(Local31.z);
		Local31.xyz = normalize(Local31.xyz);
		//[Local31] Get needed components
		float3 Local32 = Local31.xyz;
		float Local33 = Local31.w;
		//} Texture2DNode
		Local28 = Local32.xyz;
	}
	//} OverlayTextureSwitchNode
	//DynamicParameterNode {
	//} DynamicParameterNode
	float Local34 = mix(CB_MaterialConstants.FloatParameter_Fresnel_Power, in_4.x, CB_MaterialConstants.FloatParameter_Switch_DynX_Fresnel_Power);
	//FresnelNode {
	float Local35 = pow((1.0f - saturate(dot(Local28, in_5))), Local34);
	//} FresnelNode
	float Local36 = (Local27 * Local35);
	//DynamicParameterNode {
	//} DynamicParameterNode
	float Local37 = (CB_MaterialConstants.FloatParameter_DepthBlendDistance * in_4.w);
	//DepthDifferenceBlend
	float Local38 = (_LinearDepth.sample(_PointMirrorSampler, in_0).x * PerCamera.g_FarPlane);
	float Local39 = (Local38 - in_6);
	float Local40 = Local39;
	float Local41 = saturate((Local40 / max(Local37, 0.0001f)));
	//~DepthDifferenceBlend

	float3 Local42 = (CB_MaterialConstants.Vector3Parameter_SubtractiveBonePosition_Offset + CB_MaterialConstants.Vector3Parameter_SubtractiveBonePosition);
	float3 Local43 = (Local42 + float3(CB_MaterialConstants.FloatParameter_SubtractiveMaskRadius, CB_MaterialConstants.FloatParameter_SubtractiveMaskRadius, CB_MaterialConstants.FloatParameter_SubtractiveMaskRadius));
	float3 Local44 = (Local42 - Local43);
	//DotNode {
	float Local45 = dot(Local44, Local44);
	//} DotNode
	float Local46 = sqrt(Local45);
	//LocalPosition {
	//} LocalPosition
	float3 Local47 = (Local42 - in_2);
	//DotNode {
	float Local48 = dot(Local47, Local47);
	//} DotNode
	float Local49 = sqrt(Local48);
	float Local50 = (Local46 - Local49);
	float Local51 = (Local50 / Local46);
	float Local52 = clamp(Local51, 0.0f, 1.0f);
	float Local53 = (1.0f - Local52);
	float Local54 = pow(Local53, CB_MaterialConstants.FloatParameter_SubtractiveMaskIntensity);
	float Local55 = mix(1.0f, Local54, CB_MaterialConstants.FloatParameter_Switch_SubtractiveMask);
	float Local56 = (Local41 * Local55);
	float Local57 = (Local36 * Local56);
	float Local58 = (Local57 * CB_MaterialConstants.FloatParameter_PreRamp_Intensity);
	//ColorRampTextureNode {
	float4 Local59 = Texture2DParameter_ColorRamp_Texture_DefaultClampSampler.sample(_DefaultClampSampler, float2(Local58, 0.0f),  level(0.0f));
	float3 Local60 = Local59.xyz;
	//} ColorRampTextureNode
	//DynamicParameterNode {
	//} DynamicParameterNode
	float3 Local61 = (Local60 * in_4.z);
	float3 Local62 = (Local61 * CB_MaterialConstants.FloatParameter_PostRamp_Intensity);
	float3 Local63 = mix(float3(Local36, Local36, Local36), Local62, float3(CB_MaterialConstants.FloatParameter_Switch_ColorRamp, CB_MaterialConstants.FloatParameter_Switch_ColorRamp, CB_MaterialConstants.FloatParameter_Switch_ColorRamp));
	float Local64 = CB_MaterialConstants.Vector4Parameter_Color.w;
	float Local65 = (Local64 * Local3);
	float Local66 = (Local65 * Local41);
	float Local67 = (Local66 * Local56);
	float3 Local68 = mix(float3(0.0f, 0.0f, 0.0f), Local63, float3(Local67, Local67, Local67));
	float3 Local69 = (Local5 * Local68);
	float3 Local70 = (Local4 + Local69);
	out_0 = Local70;
}

fragment PixelOutput GustavX_Effects_VFX_OverlayMaterial_AlphaBlend_Unlit_Emissive_SceneColor_Fresnel_DepthBlend_WPO_LateAlpha_Spectre_01_STI_EMI_fragmentMain(constant _CB_MaterialConstants& CB_MaterialConstants [[buffer(MATERIAL_CONSTANTS_BINDING_POINT)]],
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

	CalculateMatEmissiveColor(CB_MaterialConstants, CB_EngineParams, PerFrame, PerCamera, VirtualTexture_TilesetDataBuffer, Local0, In.TexCoords0, In.LocalPosition.xyz, localNormalNormalized, In.InstanceDynamicParameter, tangentView, In.Depth, matEmissiveColor, _PointMirrorSampler, _Scene, _DefaultWrapSampler, Texture2DParameter_basecolor, Texture2DParameter_Triplanar_Texture_Map, VirtualTexture_Pagetable, _DefaultBorderSampler, VirtualTexture_Cache1, Texture2DParameter_NM, _LinearDepth, _DefaultClampSampler, Texture2DParameter_ColorRamp_Texture_DefaultClampSampler);
	Out.Color0 = float4(matEmissiveColor, 1.0f);

	return Out;
}
