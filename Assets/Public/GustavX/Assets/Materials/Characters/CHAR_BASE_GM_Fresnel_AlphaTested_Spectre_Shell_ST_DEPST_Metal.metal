#define DISABLE_PROBES

//[Vertex shader]
#include <metal_stdlib>

using namespace metal;

#include "Shaders/Metal/CommonHelpers.shdh"
#include "Shaders/Metal/Global/DS_Globals.shdh"
#include "Shaders/Metal/SkinningHelpers.shdh"
#include "Shaders/Metal/ShadowHelpers.shdh"

typedef struct
{
	float3 Position SV_POSITION0;
	float4 LocalQTangent NORMAL0;
	float2 TexCoords0 TEXCOORD0;
} VertexInput;

typedef struct
{
	float4 ProjectedPosition [[position, invariant]];
	float TetrahedronClipDistances [[clip_distance]][4];
	float3 WorldNormal;
	float3 WorldBinormal;
	float3 WorldTangent;
	float3 WorldOffset;
	float2 TexCoords0;
	float3 LocalPosition;
} VertexOutput;

struct _CB_EngineParams
{
	float4x4 WorldOffsetMatrix;
	uint TransformedVerticesOffset;
};
struct _CB_MaterialConstants
{
	packed_float3 Vector3Parameter_WPO_Strenght;
	float FloatParameter_WPO_Size;
	packed_float3 _WorldExtents;
	float FloatParameter_OutlineFresnelPower;
	packed_float3 Vector3Parameter_SubtractiveBonePosition_Offset;
	float FloatParameter_OutlineIntensity;
	packed_float3 Vector3Parameter_SubtractiveBonePosition;
	float FloatParameter_OpacityFresnelPower;
	float2 Vector2Parameter_TillingUV;
	float2 Vector2Parameter_SpeedUV;
	float FloatParameter_AlphaBoost;
	float FloatParameter_SubtractiveMaskRadius;
	float FloatParameter_SubtractiveMaskIntensity;
	float FloatParameter_Switch_SubtractiveMask;
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

vertex VertexOutput GustavX_Characters_CHAR_BASE_GM_Fresnel_AlphaTested_Spectre_Shell_ST_DEPST_vertexMain(constant _CB_MaterialConstants& CB_MaterialConstants [[buffer(MATERIAL_CONSTANTS_BINDING_POINT)]],
	constant _CB_EngineParams& CB_EngineParams [[buffer(ENGINE_PARAMS_BINDING_POINT)]],
	constant _PerFrame& PerFrame [[buffer(PER_FRAME_BINDING_POINT)]],
	constant _PerCamera& PerCamera [[buffer(PER_CAMERA_BINDING_POINT)]],
	constant const uint8_t* TransformedVertices [[buffer(TRANS_VERT_BINDING_POINT)]],
	uint VertexID [[vertex_id]],
	VertexInput In [[stage_in]])
{
	VertexOutput Out;

	float3 matWorldPositionOffset;
	CalculateMatWorldPositionOffset(CB_MaterialConstants, PerFrame, In.Position.xyz, CB_EngineParams.WorldOffsetMatrix, matWorldPositionOffset);
	float3 localPositionStatic = In.Position;
	if(CB_EngineParams.TransformedVerticesOffset > 0)
	{
		//Skinned vertex
		localPositionStatic = GetSkinnedPosition(VertexID, CB_EngineParams.TransformedVerticesOffset, TransformedVertices);
	}
	//World space offset
	float3 worldOffset = (CB_EngineParams.WorldOffsetMatrix * float4(localPositionStatic, 1.0f)).xyz;

	worldOffset = (worldOffset + matWorldPositionOffset);

	//Projected position
	float4 projectedPosition = (PerCamera.g_OffsetViewProjectionMat * float4(worldOffset, 1.0f));

	//Pass projected position to pixel shader
	Out.ProjectedPosition = projectedPosition;

	GetTetrahedronClipDistances(worldOffset, PerCamera);

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

	Out.TexCoords0 = In.TexCoords0;
	//Pass local position to pixel shader
	Out.LocalPosition = In.Position;


	return Out;
}


//[Fragment shader]
#include "Shaders/Metal/CommonHelpers.shdh"
#include "Shaders/Metal/Global/DS_Globals.shdh"

typedef struct
{
	float4 ProjectedPosition [[position]];
	float3 WorldNormal;
	float3 WorldBinormal;
	float3 WorldTangent;
	float3 WorldOffset;
	float2 TexCoords0;
	float3 LocalPosition;
} PixelInput;

typedef struct
{
} PixelOutput;

static void CalculateMatOpacity(constant _CB_MaterialConstants& CB_MaterialConstants,
	constant _PerFrame& PerFrame,
	float3 in_0,
	float2 in_1,
	float3 in_2,
	thread float& out_0,
	sampler _DefaultWrapSampler,
	texture2d<float> Texture2DParameter_Noise)
{
	//FresnelNode {
	float Local0 = pow((1.0f - saturate(dot(float3(0.0f, 1.0f, 0.0f), in_0))), CB_MaterialConstants.FloatParameter_OutlineFresnelPower);
	//} FresnelNode
	float Local1 = (Local0 * CB_MaterialConstants.FloatParameter_OutlineIntensity);
	//FresnelNode {
	float Local2 = pow((1.0f - saturate(dot(float3(0.0f, 1.0f, 0.0f), in_0))), CB_MaterialConstants.FloatParameter_OpacityFresnelPower);
	//} FresnelNode
	float Local3 = max(Local1, Local2);
	//UVNode {
	//} UVNode
	float2 Local4 = (in_1 * CB_MaterialConstants.Vector2Parameter_TillingUV);
	float2 Local5 = (PerFrame.g_CurrentTime * CB_MaterialConstants.Vector2Parameter_SpeedUV);
	float2 Local6 = (Local4 + Local5);
	//Texture2DNode {
	float4 Local7 = Texture2DParameter_Noise.sample(_DefaultWrapSampler, Local6);
	//[Local7] Get needed components
	float Local8 = Local7.x;
	//} Texture2DNode
	float Local9 = (CB_MaterialConstants.FloatParameter_AlphaBoost * Local8);
	float3 Local10 = (CB_MaterialConstants.Vector3Parameter_SubtractiveBonePosition_Offset + CB_MaterialConstants.Vector3Parameter_SubtractiveBonePosition);
	float3 Local11 = (Local10 + float3(CB_MaterialConstants.FloatParameter_SubtractiveMaskRadius, CB_MaterialConstants.FloatParameter_SubtractiveMaskRadius, CB_MaterialConstants.FloatParameter_SubtractiveMaskRadius));
	float3 Local12 = (Local10 - Local11);
	//DotNode {
	float Local13 = dot(Local12, Local12);
	//} DotNode
	float Local14 = sqrt(Local13);
	//LocalPosition {
	//} LocalPosition
	float3 Local15 = (Local10 - in_2);
	//DotNode {
	float Local16 = dot(Local15, Local15);
	//} DotNode
	float Local17 = sqrt(Local16);
	float Local18 = (Local14 - Local17);
	float Local19 = (Local18 / Local14);
	float Local20 = clamp(Local19, 0.0f, 1.0f);
	float Local21 = (1.0f - Local20);
	float Local22 = pow(Local21, CB_MaterialConstants.FloatParameter_SubtractiveMaskIntensity);
	float Local23 = mix(1.0f, Local22, CB_MaterialConstants.FloatParameter_Switch_SubtractiveMask);
	float Local24 = (Local9 * Local23);
	float Local25 = (Local3 * Local24);
	float Local26;
	Local26 = step(0.333f, Local25);
	out_0 = Local26;
}

fragment PixelOutput GustavX_Characters_CHAR_BASE_GM_Fresnel_AlphaTested_Spectre_Shell_ST_DEPST_fragmentMain(constant _CB_MaterialConstants& CB_MaterialConstants [[buffer(MATERIAL_CONSTANTS_BINDING_POINT)]],
	constant _PerFrame& PerFrame [[buffer(PER_FRAME_BINDING_POINT)]],
	PixelInput In [[stage_in]],
	sampler _DefaultWrapSampler [[sampler(DEFAULT_WRAP_SAMPLER_BINDING_POINT)]],
	texture2d<float> Texture2DParameter_Noise)
{
	PixelOutput Out;

	float matOpacity;
	float3x3 NBT_WS = float3x3(float3(In.WorldTangent.x, In.WorldNormal.x, In.WorldBinormal.x), float3(In.WorldTangent.y, In.WorldNormal.y, In.WorldBinormal.y), float3(In.WorldTangent.z, In.WorldNormal.z, In.WorldBinormal.z));

	//Normalized world space view vector
	float3 worldViewNormalized = normalize(-(In.WorldOffset));

	//Calculate tangent space view vector
	float3 tangentView = normalize((NBT_WS * worldViewNormalized));

	CalculateMatOpacity(CB_MaterialConstants, PerFrame, tangentView, In.TexCoords0, In.LocalPosition.xyz, matOpacity, _DefaultWrapSampler, Texture2DParameter_Noise);
	if ((matOpacity - 0.5f) < 0) discard_fragment();


	return Out;
}
