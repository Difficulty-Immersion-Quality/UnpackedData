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
} VertexInput;

typedef struct
{
	float4 ProjectedPosition [[position, invariant]];
} VertexOutput;

struct _CB_EngineParams
{
	packed_float3 WorldOffset;
	uint LightChannel;
};
struct _CB_MaterialConstants
{
	packed_float3 Vector3Parameter_WPO;
	float FloatParameter_Switch_WPO_HeightShimmerWave;
	packed_float3 Vector3Parameter_WPO_Strenght;
	packed_float3 _WorldExtents;
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

vertex VertexOutput GustavX_Effects_VFX_OverlayMaterial_AlphaBlend_Unlit_Emissive_SceneColor_Fresnel_DepthBlend_WPO_LateAlpha_Spectre_01_STI_DEF_vertexMain(constant _CB_MaterialConstants& CB_MaterialConstants [[buffer(MATERIAL_CONSTANTS_BINDING_POINT)]],
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


	return Out;
}


//[Fragment shader]
#include "Shaders/Metal/CommonHelpers.shdh"
#include "Shaders/Metal/PBR.shdh"

typedef struct
{
	float4 ProjectedPosition [[position]];
} PixelInput;

typedef struct
{
	float4 Color0 [[color(0)]];
	float4 Color1 [[color(1)]];
	float4 Color2 [[color(2)]];
	float4 Color3 [[color(3)]];
	float4 VTColor [[color(4)]];
} PixelOutput;

fragment PixelOutput GustavX_Effects_VFX_OverlayMaterial_AlphaBlend_Unlit_Emissive_SceneColor_Fresnel_DepthBlend_WPO_LateAlpha_Spectre_01_STI_DEF_fragmentMain(constant _CB_EngineParams& CB_EngineParams [[buffer(ENGINE_PARAMS_BINDING_POINT)]],
	PixelInput In [[stage_in]])
{
	PixelOutput Out;

	float4 VTFeedback = float4(1.0f, 1.0f, 1.0f, 1.0f);

	GBufferData gBufferData;
	gBufferData.ViewSpaceNormal = float3(0.0f, 1.0f, 0.0f);
	gBufferData.BaseColor = float3(0.0f, 0.0f, 0.0f);
	gBufferData.Occlusion = 1.0f;
	gBufferData.Roughness = 0.5f;
	gBufferData.Reflectance = 0.5f;
	gBufferData.MetalMask = 0.0f;
	gBufferData.ShadingModel = 1;
	gBufferData.LightChannel = CB_EngineParams.LightChannel;
	gBufferData.CanReceiveDeferredDecals = 0;
	gBufferData.UseFuzzyShadows = false;
	gBufferData.Custom = float4(0.0f, 0.0f, 0.0f, 0.0f);
	EncodeGBufferData(gBufferData, Out.Color0, Out.Color1, Out.Color2, Out.Color3);
	Out.VTColor = VTFeedback;

	return Out;
}
