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

    SettingSlider {
        theme: page.theme
        title: "Duration"
        description: "How long awww takes to fade to the new wallpaper."
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
        title: "Transition"
        description: "Animation awww uses when switching wallpapers."
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
        description: "How awww scales the image to fit your screen."
        options: ["Crop", "Fit", "Stretch", "Center"]
        values: ["crop", "fit", "stretch", "no"]
        currentValue: page.settings.wallpaperResize
        onSelected: (value) => page.settings.wallpaperResize = value
    }
}
