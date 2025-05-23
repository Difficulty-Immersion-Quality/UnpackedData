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
	float2 TexCoords0 TEXCOORD0;
	float4 LocalQTangent NORMAL0;
} VertexInput;

typedef struct
{
	float4 ProjectedPosition [[position, invariant]];
	float2 TexCoords0;
	float3 WorldNormal;
	float3 WorldBinormal;
	float3 WorldTangent;
	float3 WorldOffset;
} VertexOutput;

struct _CB_MaterialConstants
{
	packed_float3 Vector3Parameter_WPO_Strenght;
	float FloatParameter_WPO_Size;
	packed_float3 _WorldExtents;
	float FloatParameter_GlowColorIntensity;
	packed_float3 Vector3Parameter_GlowColor2;
	float FloatParameter_OutlineFresnelPower;
	packed_float3 Vector3Parameter_GlowColor3;
	float FloatParameter_OutlineIntensity;
	packed_float3 Vector3Parameter_GlowColor1;
	packed_float3 Vector3Parameter_OutlineColor;
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

vertex VertexOutput GustavX_Characters_CHAR_BASE_GM_Fresnel_AlphaTested_Spectre_Shell_STI_EMI_vertexMain(constant _CB_MaterialConstants& CB_MaterialConstants [[buffer(MATERIAL_CONSTANTS_BINDING_POINT)]],
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

	Out.TexCoords0 = In.TexCoords0;
	//Compute localTangentFrame tangent frame
	float3x3 localTangentFrame = GetTangentFrame(In.LocalQTangent);

	float3 localNormal = localTangentFrame[2];

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


	return Out;
}


//[Fragment shader]
#include "Shaders/Metal/CommonHelpers.shdh"

typedef struct
{
	float4 ProjectedPosition [[position]];
	float2 TexCoords0;
	float3 WorldNormal;
	float3 WorldBinormal;
	float3 WorldTangent;
	float3 WorldOffset;
} PixelInput;

typedef struct
{
	float4 Color0 [[color(0)]];
} PixelOutput;

static void CalculateMatEmissiveColor(constant _CB_MaterialConstants& CB_MaterialConstants,
	float2 in_0,
	float3 in_1,
	thread float3& out_0,
	sampler _DefaultWrapSampler,
	texture2d<float> Texture2DParameter_MSKgradient)
{
	//Texture2DNode {
	float4 Local0 = Texture2DParameter_MSKgradient.sample(_DefaultWrapSampler, in_0);
	//[Local0] Get needed components
	float Local1 = Local0.x;
	//} Texture2DNode
	float Local2 = step(Local1, 0.5f);
	float Local3 = (1.0f - Local2);
	float Local4 = (0.0f + (((Local1 - 0.5f) * (1.0f - 0.0f)) / max(abs((1.0f - 0.5f)), 1E-05f)));
	float3 Local5 = mix(CB_MaterialConstants.Vector3Parameter_GlowColor2, CB_MaterialConstants.Vector3Parameter_GlowColor3, float3(Local4, Local4, Local4));
	float3 Local6 = (Local3 * Local5);
	float Local7 = (0.0f + (((Local1 - 0.0f) * (1.0f - 0.0f)) / max(abs((0.5f - 0.0f)), 1E-05f)));
	float3 Local8 = mix(CB_MaterialConstants.Vector3Parameter_GlowColor1, CB_MaterialConstants.Vector3Parameter_GlowColor2, float3(Local7, Local7, Local7));
	float3 Local9 = (Local2 * Local8);
	float3 Local10 = (Local6 + Local9);
	float3 Local11 = (CB_MaterialConstants.FloatParameter_GlowColorIntensity * Local10);
	//FresnelNode {
	float Local12 = pow((1.0f - saturate(dot(float3(0.0f, 1.0f, 0.0f), in_1))), CB_MaterialConstants.FloatParameter_OutlineFresnelPower);
	//} FresnelNode
	float Local13 = (Local12 * CB_MaterialConstants.FloatParameter_OutlineIntensity);
	float3 Local14 = (Local13 * CB_MaterialConstants.Vector3Parameter_OutlineColor);
	float Local15 = clamp(Local13, 0.0f, 1.0f);
	float3 Local16 = mix(Local11, Local14, float3(Local15, Local15, Local15));
	out_0 = Local16;
}

fragment PixelOutput GustavX_Characters_CHAR_BASE_GM_Fresnel_AlphaTested_Spectre_Shell_STI_EMI_fragmentMain(constant _CB_MaterialConstants& CB_MaterialConstants [[buffer(MATERIAL_CONSTANTS_BINDING_POINT)]],
	PixelInput In [[stage_in]],
	sampler _DefaultWrapSampler [[sampler(DEFAULT_WRAP_SAMPLER_BINDING_POINT)]],
	texture2d<float> Texture2DParameter_MSKgradient)
{
	PixelOutput Out;

	float3 matEmissiveColor;
	float3x3 NBT_WS = float3x3(float3(In.WorldTangent.x, In.WorldNormal.x, In.WorldBinormal.x), float3(In.WorldTangent.y, In.WorldNormal.y, In.WorldBinormal.y), float3(In.WorldTangent.z, In.WorldNormal.z, In.WorldBinormal.z));

	//Normalized world space view vector
	float3 worldViewNormalized = normalize(-(In.WorldOffset));

	//Calculate tangent space view vector
	float3 tangentView = normalize((NBT_WS * worldViewNormalized));

	CalculateMatEmissiveColor(CB_MaterialConstants, In.TexCoords0, tangentView, matEmissiveColor, _DefaultWrapSampler, Texture2DParameter_MSKgradient);
	Out.Color0 = float4(matEmissiveColor, 1.0f);

	return Out;
}
