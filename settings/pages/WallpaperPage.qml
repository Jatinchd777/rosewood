import QtQuick
import Quickshell
import "../components/"

PageContent {
    id: page

    property var settings

    title: "Wallpaper"
    description: "Where wallpapers come from and how they animate."

    SectionTitle {
        theme: page.theme
        text: "SOURCE"
    }

    SettingText {
        theme: page.theme
        title: "Wallpaper directory"
        description: "Folder scanned by the wallpaper picker. ~ is supported."
        value: page.settings.wallpaperDirectory
        placeholder: "~/Pictures/wallpapers"
        onEdited: (text) => {
            if (text.trim().length > 0)
                page.settings.wallpaperDirectory = text
        }
    }

    InfoNote {
        theme: page.theme
        icon: "󰉋"
        text: "Resolved path: " + page.settings.wallpaperDirectoryResolved
    }

    ActionButton {
        theme: page.theme
        icon: "󰉋"
        text: "Open wallpaper folder"
        onClicked: Quickshell.execDetached(["xdg-open", page.settings.wallpaperDirectoryResolved])
    }

    SectionTitle {
        theme: page.theme
        text: "TRANSITION"
    }

    SettingChoice {
        theme: page.theme
        title: "Effect"
        description: "Auto draws the outline when the wallpaper has a prepared character, otherwise the pixel colonies. Classic keeps awww."
        options: ["Auto", "Contagion", "Outline", "Classic"]
        values: ["auto", "contagion", "outline", "classic"]
        currentValue: page.settings.wallpaperEffect
        onSelected: (value) => page.settings.wallpaperEffect = value
    }

    InfoNote {
        theme: page.theme
        icon: "󰐊"
        text: "Outline needs the optional cut-out environment (scripts/wallfx instalar). Without it, Auto and Outline fall back to Contagion."
    }

    SettingSlider {
        theme: page.theme
        title: "Duration"
        description: "Length of the shader transition, and of the awww fallback."
        from: 0
        to: 2
        stepSize: 0.05
        value: page.settings.wallpaperTransition
        decimals: 2
        suffix: " s"
        onMoved: (value) => page.settings.wallpaperTransition = value
    }

    SettingChoice {
        theme: page.theme
        title: "Classic transition"
        description: "Animation awww uses when Effect is Classic, the shader is unavailable, or the fill mode is not Crop."
        options: ["Random", "Fade", "Wipe", "Grow", "Wave"]
        values: ["random", "fade", "wipe", "grow", "wave"]
        currentValue: page.settings.wallpaperTransitionType
        onSelected: (value) => page.settings.wallpaperTransitionType = value
    }

    SectionTitle {
        theme: page.theme
        text: "LAYOUT"
    }

    SettingChoice {
        theme: page.theme
        title: "Fill mode"
        description: "How awww scales the image. The shader transition supports Crop only; other modes use the classic transition."
        options: ["Crop", "Fit", "Stretch", "Center"]
        values: ["crop", "fit", "stretch", "no"]
        currentValue: page.settings.wallpaperResize
        onSelected: (value) => page.settings.wallpaperResize = value
    }
}
