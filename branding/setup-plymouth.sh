#!/bin/bash

# Plymouth Theme Setup Script for TAKERMAN branding

# Create Plymouth theme directory
mkdir -p /usr/share/plymouth/themes/takerman

# Create TAKERMAN Plymouth theme
cat > /usr/share/plymouth/themes/takerman/takerman.plymouth << 'EOF'
[Plymouth Theme]
Name=TAKERMAN AI Server
Description=TAKERMAN AI Server OS
ModuleName=script

[script]
ImageDir=/usr/share/plymouth/themes/takerman
ScriptFile=/usr/share/plymouth/themes/takerman/takerman.script
EOF

# Create Plymouth script
cat > /usr/share/plymouth/themes/takerman/takerman.script << 'EOF'
# TAKERMAN AI Server Plymouth Boot Script

# Screen setup
screen_width = Window.GetWidth();
screen_height = Window.GetHeight();

# Colors (night tech theme)
bg_color.red = 0.05;
bg_color.green = 0.05; 
bg_color.blue = 0.15;

text_color.red = 0.0;
text_color.green = 1.0;
text_color.blue = 1.0;

accent_color.red = 0.5;
accent_color.green = 0.0;
accent_color.blue = 1.0;

# Background
Window.SetBackgroundTopColor(bg_color);
Window.SetBackgroundBottomColor(bg_color);

# TAKERMAN Logo ASCII Art
logo_text[0] = " ████████╗ █████╗ ██╗  ██╗███████╗██████╗ ███╗   ███╗ █████╗ ███╗   ██╗";
logo_text[1] = " ╚══██╔══╝██╔══██╗██║ ██╔╝██╔════╝██╔══██╗████╗ ████║██╔══██╗████╗  ██║";
logo_text[2] = "    ██║   ███████║█████╔╝ █████╗  ██████╔╝██╔████╔██║███████║██╔██╗ ██║";
logo_text[3] = "    ██║   ██╔══██║██╔═██╗ ██╔══╝  ██╔══██╗██║╚██╔╝██║██╔══██║██║╚██╗██║";
logo_text[4] = "    ██║   ██║  ██║██║  ██╗███████╗██║  ██║██║ ╚═╝ ██║██║  ██║██║ ╚████║";
logo_text[5] = "    ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝";

# Position logo
logo_y = screen_height / 2 - 100;
for (i = 0; i < 6; i++) {
    logo_image[i] = Image.Text(logo_text[i], text_color.red, text_color.green, text_color.blue, 1);
    logo_sprite[i] = Sprite(logo_image[i]);
    logo_sprite[i].SetX((screen_width - logo_image[i].GetWidth()) / 2);
    logo_sprite[i].SetY(logo_y + i * 20);
}

# Subtitle
subtitle_image = Image.Text("🚀 AI SERVER 🚀", accent_color.red, accent_color.green, accent_color.blue, 1);
subtitle_sprite = Sprite(subtitle_image);
subtitle_sprite.SetX((screen_width - subtitle_image.GetWidth()) / 2);
subtitle_sprite.SetY(logo_y + 140);

# Website URL
url_image = Image.Text("https://takerman.net", text_color.red, text_color.green, text_color.blue, 0.8);
url_sprite = Sprite(url_image);
url_sprite.SetX((screen_width - url_image.GetWidth()) / 2);
url_sprite.SetY(logo_y + 180);

# Loading animation
progress = 0;
fun refresh_callback() {
    progress++;
    
    # Animated dots
    dots = "";
    dot_count = (progress / 10) % 4;
    for (i = 0; i < dot_count; i++) {
        dots += "●";
    }
    for (i = dot_count; i < 3; i++) {
        dots += "○";
    }
    
    loading_text = "Loading TAKERMAN AI Server " + dots;
    loading_image = Image.Text(loading_text, text_color.red, text_color.green, text_color.blue, 0.9);
    loading_sprite = Sprite(loading_image);
    loading_sprite.SetX((screen_width - loading_image.GetWidth()) / 2);
    loading_sprite.SetY(screen_height - 100);
}

Plymouth.SetRefreshFunction(refresh_callback);

# Boot progress
fun boot_progress_callback(duration, progress) {
    if (progress >= 0) {
        progress_bar_width = 400;
        progress_bar_height = 8;
        
        # Progress bar background
        progress_bg = Image.Text(" ", bg_color.red, bg_color.green, bg_color.blue);
        progress_bg = progress_bg.Scale(progress_bar_width, progress_bar_height);
        progress_bg_sprite = Sprite(progress_bg);
        progress_bg_sprite.SetX((screen_width - progress_bar_width) / 2);
        progress_bg_sprite.SetY(screen_height - 60);
        
        # Progress bar fill
        progress_fill_width = progress_bar_width * progress;
        if (progress_fill_width > 0) {
            progress_fill = Image.Text(" ", accent_color.red, accent_color.green, accent_color.blue);
            progress_fill = progress_fill.Scale(progress_fill_width, progress_bar_height);
            progress_fill_sprite = Sprite(progress_fill);
            progress_fill_sprite.SetX((screen_width - progress_bar_width) / 2);
            progress_fill_sprite.SetY(screen_height - 60);
        }
    }
}

Plymouth.SetBootProgressFunction(boot_progress_callback);
EOF

# Install and activate the theme
update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/takerman/takerman.plymouth 100
update-alternatives --set default.plymouth /usr/share/plymouth/themes/takerman/takerman.plymouth

# Update initramfs
update-initramfs -u