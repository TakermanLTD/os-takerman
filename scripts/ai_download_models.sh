
# Download AI models
echo "Downloading AI models in background..."

# Checkpoints
# wget -b -O /mnt/media/ai/comfyui/models/checkpoints/v1-5-pruned-emaonly-fp16.safetensors https://huggingface.co/Comfy-Org/stable-diffusion-v1-5-archive/resolve/main/v1-5-pruned-emaonly-fp16.safetensors
wget -b -O /mnt/media/ai/comfyui/models/checkpoints/dreamshaper_8.safetensors https://civitai.com/api/download/models/128713?type=Model&format=SafeTensor&size=pruned&fp=fp16
# wget -b -O /mnt/media/ai/comfyui/models/checkpoints/flux1-dev-fp8.safetensors https://huggingface.co/Comfy-Org/flux1-dev/resolve/main/flux1-dev-fp8.safetensors
wget -b -O /mnt/media/ai/comfyui/models/checkpoints/flux1-schnell-fp8.safetensors https://huggingface.co/Comfy-Org/flux1-schnell/resolve/main/flux1-schnell-fp8.safetensors
# wget -b -O /mnt/media/ai/comfyui/models/checkpoints/sd3.5_large_fp8_scaled.safetensors https://huggingface.co/Comfy-Org/stable-diffusion-3.5-fp8/resolve/main/sd3.5_large_fp8_scaled.safetensors
# wget -b -O /mnt/media/ai/comfyui/models/checkpoints/sd_xl_base_1.0.safetensors https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors
# wget -b -O /mnt/media/ai/comfyui/models/checkpoints/sd_xl_refiner_1.0.safetensors https://huggingface.co/stabilityai/stable-diffusion-xl-refiner-1.0/resolve/main/sd_xl_refiner_1.0.safetensors
# wget -b -O /mnt/media/ai/comfyui/models/checkpoints/sd_xl_turbo_1.0_fp16.safetensors https://huggingface.co/stabilityai/sdxl-turbo/resolve/main/sd_xl_turbo_1.0_fp16.safetensors
# wget -b -O /mnt/media/ai/comfyui/models/checkpoints/stable-audio-open-1.0.safetensors https://huggingface.co/Comfy-Org/stable-audio-open-1.0_repackaged/resolve/main/stable-audio-open-1.0.safetensors
# wget -b -O /mnt/media/ai/comfyui/models/checkpoints/ace_step_v1_3.5b.safetensors https://huggingface.co/Comfy-Org/ACE-Step_ComfyUI_repackaged/resolve/main/all_in_one/ace_step_v1_3.5b.safetensors

# LoRAs
# wget -b -O /mnt/media/ai/comfyui/models/loras/MoXinV1.safetensors https://civitai.com/api/download/models/14856?type=Model&format=SafeTensor&size=full&fp=fp16
# wget -b -O /mnt/media/ai/comfyui/models/loras/blindbox_v1_mix.safetensors https://civitai.com/api/download/models/32988?type=Model&format=SafeTensor&size=full&fp=fp16

# VAE Models
# wget -b -O /mnt/media/ai/comfyui/models/vae/ae.safetensors https://huggingface.co/Comfy-Org/Lumina_Image_2.0_Repackaged/resolve/main/split_files/vae/ae.safetensors
# wget -b -O /mnt/media/ai/comfyui/models/vae/wan_2.1_vae.safetensors https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors

# Text Encoders
# wget -b -O /mnt/media/ai/comfyui/models/text_encoders/clip_l.safetensors https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors
# wget -b -O /mnt/media/ai/comfyui/models/text_encoders/t5xxl_fp16.safetensors https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors
# wget -b -O /mnt/media/ai/comfyui/models/text_encoders/qwen_2.5_vl_fp16.safetensors https://huggingface.co/Comfy-Org/Omnigen2_ComfyUI_repackaged/resolve/main/split_files/text_encoders/qwen_2.5_vl_fp16.safetensors
# wget -b -O /mnt/media/ai/comfyui/models/text_encoders/t5-base.safetensors https://huggingface.co/ComfyUI-Wiki/t5-base/resolve/main/t5-base.safetensors
# wget -b -O /mnt/media/ai/comfyui/models/text_encoders/oldt5_xxl_fp8_e4m3fn_scaled.safetensors https://huggingface.co/comfyanonymous/cosmos_1.0_text_encoder_and_VAE_ComfyUI/resolve/main/text_encoders/oldt5_xxl_fp8_e4m3fn_scaled.safetensors
# wget -b -O /mnt/media/ai/comfyui/models/text_encoders/clip_l_hidream.safetensors https://huggingface.co/Comfy-Org/HiDream-I1_ComfyUI/resolve/main/split_files/text_encoders/clip_l_hidream.safetensors
# wget -b -O /mnt/media/ai/comfyui/models/text_encoders/clip_g_hidream.safetensors https://huggingface.co/Comfy-Org/HiDream-I1_ComfyUI/resolve/main/split_files/text_encoders/clip_g_hidream.safetensors
# wget -b -O /mnt/media/ai/comfyui/models/text_encoders/t5xxl_fp8_e4m3fn_scaled.safetensors https://huggingface.co/Comfy-Org/HiDream-I1_ComfyUI/resolve/main/split_files/text_encoders/t5xxl_fp8_e4m3fn_scaled.safetensors

# Diffusion Models
# wget -b -O /mnt/media/ai/comfyui/models/diffusion_models/flux1-dev.safetensors https://huggingface.co/Comfy-Org/flux1-dev/resolve/main/flux1-dev.safetensors
# wget -b -O /mnt/media/ai/comfyui/models/diffusion_models/omnigen2_fp16.safetensors https://huggingface.co/Comfy-Org/Omnigen2_ComfyUI_repackaged/resolve/main/split_files/diffusion_models/omnigen2_fp16.safetensors
# wget -b -O /mnt/media/ai/comfyui/models/diffusion_models/cosmos_predict2_2B_t2i.safetensors https://huggingface.co/Comfy-Org/Cosmos_Predict2_repackaged/resolve/main/cosmos_predict2_2B_t2i.safetensors
# wget -b -O /mnt/media/ai/comfyui/models/diffusion_models/hidream_i1_full_fp8.safetensors https://huggingface.co/Comfy-Org/HiDream-I1_ComfyUI/resolve/main/split_files/diffusion_models/hidream_i1_full_fp8.safetensors

# Style Models
# wget -b -O /mnt/media/ai/comfyui/models/style_models/flux1-redux-dev.safetensors https://huggingface.co/Comfy-Org/Flux1-Redux-Dev/resolve/main/flux1-redux-dev.safetensors

# CLIP Vision Models
# wget -b -O /mnt/media/ai/comfyui/models/clip_vision/sigclip_vision_patch14_384.safetensors https://huggingface.co/Comfy-Org/sigclip_vision_384/resolve/main/sigclip_vision_patch14_384.safetensors

echo "All model downloads started in background. Check download progress with 'jobs' command."