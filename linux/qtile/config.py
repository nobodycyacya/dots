import os
import subprocess
from libqtile import bar, layout, qtile, widget, hook
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal

catppuccin = {
    "rosewater": "#f5e0dc",
    "flamingo": "#f2cdcd",
    "pink": "#f5c2e7",
    "mauve": "#cba6f7",
    "red": "#f38ba8",
    "maroon": "#eba0ac",
    "peach": "#fab387",
    "yellow": "#f9e2af",
    "green": "#a6e3a1",
    "teal": "#94e2d5",
    "sky": "#89dceb",
    "sapphire": "#74c7ec",
    "blue": "#89b4fa",
    "lavender": "#b4befe",
    "text": "#cdd6f4",
    "subtext1": "#bac2de",
    "subtext0": "#a6adc8",
    "overlay2": "#9399b2",
    "overlay1": "#7f849c",
    "overlay0": "#6c7086",
    "surface2": "#585b70",
    "surface1": "#45475a",
    "surface0": "#313244",
    "base": "#1e1e2e",
    "mantle": "#181825",
    "crust": "#11111b",
}

@hook.subscribe.startup_once
def autostart():
    commands = [
        "dunst",
        "xclip",
        "nm-applet",
        "flameshot",
        "blueman-applet",
        "udiskie --tray",
        "/usr/lib/polkit-kde-authentication-agent-1",
        "xrdb -merge /home/cya/.Xresources",
        "ibus-daemon -drxR",
        "redshift -x && redshift -O 4500",
    ]
    for cmd in commands:
        subprocess.Popen(cmd, shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

mod = "mod4"
keys = [
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "space", lazy.layout.next(), desc="Move window focus to other window"),
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window to the left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(), desc="Move window to the right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),
    Key([mod, "control"], "h", lazy.layout.grow_left(), lazy.layout.grow().when(layout=["monadtall"])),
    Key([mod, "control"], "l", lazy.layout.grow_right(), lazy.layout.shrink().when(layout=["monadtall"])),
    Key([mod, "control"], "j", lazy.layout.grow_down(), lazy.layout.grow().when(layout=["monadtall"])),
    Key([mod, "control"], "k", lazy.layout.grow_up(), lazy.layout.shrink().when(layout=["monadtall"])),
    Key([mod], "Return", lazy.spawn("kitty"), desc="Launch terminal"),
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod, "shift"], "q", lazy.window.kill(), desc="Kill focused window"),
    Key([mod], "f", lazy.window.toggle_fullscreen(), desc="Toggle fullscreen on the focused window"),
    Key([mod, "shift"], "f", lazy.window.toggle_floating(), desc="Toggle floating on the focused window"),
    Key([mod, "shift"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "shift"], "e", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod], "space", lazy.spawncmd(), desc="Spawn a command using a prompt widget"),
    Key([mod, "shift"], "space", lazy.spawn("rofi -show run"), desc="AppLauncher"),
    Key([], "XF86AudioRaiseVolume", lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%"), desc="Raise Volume"),
    Key([], "XF86AudioLowerVolume", lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%"), desc="Lower Volume"),
    Key([], "XF86AudioMute", lazy.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle"), desc="Audio Mute"),
    Key([], "XF86MonBrightnessDown", lazy.spawn("brightnessctl s 5%-"), desc="Lower Monitor Brightness"),
    Key([], "XF86MonBrightnessUp", lazy.spawn("brightnessctl s +5%"), desc="Raise Monitor Brightness")
]

for vt in range(1, 8):
    keys.append(
        Key(
            ["control", "mod1"],
            f"f{vt}",
            lazy.core.change_vt(vt).when(func=lambda: qtile.core.name == "wayland"),
            desc=f"Switch to VT{vt}",
        )
    )


groups = [Group(i) for i in "1234567890"]

for i in groups:
    keys.extend(
        [
            Key([mod], i.name, lazy.group[i.name].toscreen(), desc=f"Switch to group {i.name}"),
            Key([mod, "shift"], i.name, lazy.window.togroup(i.name, switch_group=True), desc=f"Switch to & move focused window to group {i.name}"),
        ]
    )

layouts = [
    # layout.Columns(),
    # layout.Max(),
    # Try more layouts by unleashing below layouts.
    # layout.Stack(num_stacks=2),
    # layout.Bsp(),
    # layout.Matrix(),
    layout.MonadTall(border_width=4, margin=4, border_focus=catppuccin["green"], border_normal=catppuccin["surface2"]),
    # layout.MonadWide(),
    # layout.RatioTile(),
    # layout.Tile(),
    # layout.TreeTab(),
    # layout.VerticalTile(),
    # layout.Zoomy(),
]

widget_defaults = dict(
    font="JetBrainsMono Nerd Font Semibold",
    fontsize=15,
    padding=3,
    background=catppuccin["crust"],
    foreground=catppuccin["text"],
)
extension_defaults = widget_defaults.copy()

screens = [
    Screen(
        wallpaper = "/home/cya/wallpaper/wp1.png",
        wallpaper_mode = "fill",
        bottom=bar.Bar(
            [
                widget.TextBox('  ', foreground=catppuccin["rosewater"]),
                widget.Prompt(cursor_color=catppuccin["red"], prompt="Run: "),
                widget.GroupBox(highlight_method="border", active=catppuccin["text"], inactive=catppuccin["surface1"], this_current_screen_border=catppuccin["green"], hide_unused=True),
                widget.CurrentLayoutIcon(scale=0.75),
                widget.WindowName(),
                widget.TextBox(text="  ", foreground=catppuccin["red"]),
                widget.CPU(format="{load_percent:.0f}%"),
                widget.TextBox(text="  ", foreground=catppuccin["peach"]),
                widget.Memory(format="{MemPercent:.0f}%"),
                widget.TextBox(text=" 󰕾 ", foreground=catppuccin["lavender"]),
                widget.Volume(fmt="{}"),
                widget.TextBox(text="  ", foreground=catppuccin["yellow"]),
                widget.Backlight(format="{percent:2.0%}", backlight_name="intel_backlight"),
                widget.TextBox(text=" 󱈏 ", foreground=catppuccin["green"]),
                widget.Battery(format="{percent:2.0%}"),
                widget.TextBox(text=" 󰃰 ", foreground=catppuccin["mauve"]),
                widget.Clock(format="%Y-%m-%d %H:%M"),
                widget.Systray(),
            ],
            30,
            # border_width=[2, 0, 2, 0],  # Draw top and bottom borders
            # border_color=["ff00ff", "000000", "ff00ff", "000000"]  # Borders are magenta
        ),
        # x11_drag_polling_rate = 60,
    ),
]

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []
follow_mouse_focus = True
bring_front_click = False
floats_kept_above = True
cursor_warp = False
floating_layout = layout.Floating(
    float_rules=[
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),
        Match(wm_class="makebranch"),
        Match(wm_class="maketag"),
        Match(wm_class="ssh-askpass"),
        Match(title="branchdialog"),
        Match(title="pinentry"),
    ]
)
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True
auto_minimize = True
wl_input_rules = None
wl_xcursor_theme = None
wl_xcursor_size = 24
wmname = "LG3D"
