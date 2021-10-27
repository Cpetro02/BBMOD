# Core shaders
Xpanda .\shaders\BBMOD_ShDefault --x .\Xshaders\         ANIMATED=0 BATCHED=0 PBR=0 OUTPUT_DEPTH=0
Xpanda .\shaders\BBMOD_ShDefaultAnimated --x .\Xshaders\ ANIMATED=1 BATCHED=0 PBR=0 OUTPUT_DEPTH=0
Xpanda .\shaders\BBMOD_ShDefaultBatched --x .\Xshaders\  ANIMATED=0 BATCHED=1 PBR=0 OUTPUT_DEPTH=0

# PBR shaders
Xpanda .\shaders\BBMOD_ShPBR --x .\Xshaders\             ANIMATED=0 BATCHED=0 PBR=1 OUTPUT_DEPTH=0
Xpanda .\shaders\BBMOD_ShPBRAnimated --x .\Xshaders\     ANIMATED=1 BATCHED=0 PBR=1 OUTPUT_DEPTH=0
Xpanda .\shaders\BBMOD_ShPBRBatched --x .\Xshaders\      ANIMATED=0 BATCHED=1 PBR=1 OUTPUT_DEPTH=0

# Shadow mapping shaders
Xpanda .\shaders\BBMOD_ShDepth --x .\Xshaders\           ANIMATED=0 BATCHED=0 PBR=0 OUTPUT_DEPTH=1
Xpanda .\shaders\BBMOD_ShDepthAnimated --x .\Xshaders\   ANIMATED=1 BATCHED=0 PBR=0 OUTPUT_DEPTH=1
Xpanda .\shaders\BBMOD_ShDepthBatched --x .\Xshaders\    ANIMATED=0 BATCHED=1 PBR=0 OUTPUT_DEPTH=1
