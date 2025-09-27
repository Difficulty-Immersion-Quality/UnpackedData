#define DISABLE_PROBES

//[Vertex shader]
#include <metal_stdlib>

using namespace metal;

#include "Shaders/Metal/CommonHelpers.shdh"
#include "Shaders/Metal/Global/DS_Globals.shdh"

typedef struct
{
	float3 Position SV_POSITION0;
	float4 InstanceMatrix1 COLOR1;
	float4 InstanceMatrix2 COLOR2;
	float4 InstanceMatrix3 COLOR3;
	float4 LocalQTangent NORMAL0;
} VertexInput;

typedef struct
{
	float4 ProjectedPosition [[position, invariant]];
	float3 ViewNormal;
} VertexOutput;

struct _CB_MaterialConstants
{
	packed_float3 Vector3Parameter_WPO_Strenght;
	float FloatParameter_WPO_Size;
	packed_float3 _WorldExtents;
};
static void CalculateMatWorldPositionOffset(constant _CB_MaterialConstants& CB_MaterialConstants,
	constant _PerFrame& PerFrame,
	float3 in_0,
	float4x4 in_1,
	thread float3& out_0)
{
	//LocalPosition {
	//} LocalPosition
	float Local0 = in_0.y;
	float Local1 = (CB_MaterialConstants._WorldExtents.y * CB_MaterialConstants.FloatParameter_WPO_Size);
	float Local2 = (Local0 / Local1);
	float Local3 = (PerFrame.g_CurrentTime + Local2);
	// TriangleWaveNode {
	//TriangleWave
	float Local4 = abs(((fract((Local3 + 0.5f)) * 2.0f) - 1.0f));
	//Smooth TriangleWave
	float Local5 = ((Local4 * Local4) * (3.0f - (2.0f * Local4)));
	// } TriangleWaveNode
	float3 Local6 = (CB_MaterialConstants.Vector3Parameter_WPO_Strenght * Local5);
	//TransformDirectionNode {
	float3 Local7 = (float3x3(in_1[0].xyz, in_1[1].xyz, in_1[2].xyz) * Local6);
	//} TransformDirectionNode
	out_0 = Local7;
}

vertex VertexOutput GustavX_Characters_CHAR_BASE_GM_Fresnel_AlphaTested_Spectre_Shell_STI_DEF_vertexMain(constant _CB_MaterialConstants& CB_MaterialConstants [[buffer(MATERIAL_CONSTANTS_BINDING_POINT)]],
	constant _PerFrame& PerFrame [[buffer(PER_FRAME_BINDING_POINT)]],
	constant _PerCamera& PerCamera [[buffer(PER_CAMERA_BINDING_POINT)]],
	VertexInput In [[stage_in]])
{
	VertexOutput Out;

	float3 matWorldPositionOffset;
	//Create Instance WorldOffset Matrix
	float4x4 noBillboardWorldOffsetMatrix = float4x4(float4(In.InstanceMatrix1.x, In.InstanceMatrix2.x, In.InstanceMatrix3.x, 0.0f), float4(In.InstanceMatrix1.y, In.InstanceMatrix2.y, In.InstanceMatrix3.y, 0.0f), float4(In.InstanceMatrix1.z, In.InstanceMatrix2.z, In.InstanceMatrix3.z, 0.0f), float4(In.InstanceMatrix1.w, In.InstanceMatrix2.w, In.InstanceMatrix3.w, 1.0f));

	CalculateMatWorldPositionOffset(CB_MaterialConstants, PerFrame, In.Position.xyz, noBillboardWorldOffsetMatrix, matWorldPositionOffset);
	float3 localPositionStatic = In.Position;
	//World space offset
	float3 worldOffset = (noBillboardWorldOffsetMatrix * float4(localPositionStatic, 1.0f)).xyz;

	worldOffset = (worldOffset + matWorldPositionOffset);

	//Projected position
	float4 projectedPosition = (PerCamera.g_OffsetViewProjectionMat * float4(worldOffset, 1.0f));

	//Pass projected position to pixel shader
	Out.ProjectedPosition = projectedPosition;

	//Compute localTangentFrame tangent frame
	float3x3 localTangentFrame = GetTangentFrame(In.LocalQTangent);

	float3 localNormal = localTangentFrame[2];

	//World space Normal
	float3 worldNormal = (float3x3(noBillboardWorldOffsetMatrix[0].xyz, noBillboardWorldOffsetMatrix[1].xyz, noBillboardWorldOffsetMatrix[2].xyz) * localNormal);

	float3 viewSpaceNormal = (float3x3(PerCamera.g_ViewMat[0].xyz, PerCamera.g_ViewMat[1].xyz, PerCamera.g_ViewMat[2].xyz) * worldNormal);

	Out.ViewNormal = viewSpaceNormal;


	return Out;
}


//[Fragment shader]
#include "Shaders/Metal/CommonHelpers.shdh"
#include "Shaders/Metal/PBR.shdh"

typedef struct
{
	float4 ProjectedPosition [[position]];
	float3 ViewNormal;
} PixelInput;

typedef struct
{
	float4 Color0 [[color(0)]];
	float4 Color1 [[color(1)]];
	float4 Color2 [[color(2)]];
	float4 Color3 [[color(3)]];
} PixelOutput;

struct _CB_EngineParams
{
	uint LightChannel;
};
fragment PixelOutput GustavX_Characters_CHAR_BASE_GM_Fresnel_AlphaTested_Spectre_Shell_STI_DEF_fragmentMain(constant _CB_EngineParams& CB_EngineParams [[buffer(ENGINE_PARAMS_BINDING_POINT)]],
	PixelInput In [[stage_in]])
{
	PixelOutput Out;

	float3 viewNormalNormalized = normalize(In.ViewNormal);

	float matOcclusion = 1.0f;
	GBufferData gBufferData;
	gBufferData.ViewSpaceNormal = viewNormalNormalized;
	gBufferData.BaseColor = float3(0.0f, 0.0f, 0.0f);
	gBufferData.Occlusion = matOcclusion;
	gBufferData.Roughness = 0.5f;
	gBufferData.Reflectance = 0.5f;
	gBufferData.MetalMask = 0.0f;
	gBufferData.ShadingModel = 0;
	gBufferData.LightChannel = CB_EngineParams.LightChannel;
	gBufferData.CanReceiveDeferredDecals = 0;
	gBufferData.UseFuzzyShadows = false;
	gBufferData.Custom = float4(0.0f, 0.0f, 0.0f, 0.0f);
	EncodeGBufferData(gBufferData, Out.Color0, Out.Color1, Out.Color2, Out.Color3);

	return Out;
}
