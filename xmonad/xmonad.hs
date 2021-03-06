-- An example, simple ~/.xmonad/xmonad.hs file.
-- It overrides a few basic settings, reusing all the other defaults.


import XMonad
import XMonad.Layout.Spacing
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.EwmhDesktops
import XMonad.Layout.Gaps
import XMonad.Layout.NoBorders
import XMonad.Layout.Fullscreen hiding (fullscreenEventHook)
import XMonad.Util.SpawnOnce
import XMonad.Util.Run
import XMonad.Util.NamedWindows
import XMonad.Actions.Warp
import qualified XMonad.StackSet as W
import Graphics.X11.ExtraTypes.XF86

import Data.Ratio
import Data.List
import Data.Function
import Control.Monad

import qualified Data.Map as M

myLayoutHook = fullscreenFocus . lessBorders Screen . spacing 5 . gaps [(U, 35)] $ layoutHook def
myEventHook  = handleEventHook def <+> fullscreenEventHook
myLogHook = logHook def
myStartupHook = do
    startupHook def
    setFullscreenSupported
    spawnOnce "polybar top"
    spawnOnce "dunst"
    -- setWMName "LG3D"

myKeys = (\c -> M.fromList $ [ ((0, xF86XK_AudioLowerVolume), spawn "amixer -q sset Master 2%-")
                           , ((0, xF86XK_AudioRaiseVolume), spawn "amixer -q sset Master 2%+")
                           , ((0, xF86XK_AudioMute), spawn "pactl set-sink-mute 0 toggle")
                           , ((0, xF86XK_MonBrightnessUp), spawn "xbacklight -inc 10")
                           , ((0, xF86XK_MonBrightnessDown), spawn "xbacklight -dec 10")
                           , ((0, xK_Print), spawn "screenshot /home/birk/media/screenshots")
                           , ((shiftMask, xK_Print), spawn "screenshot -r /home/birk/media/screenshots")
                           --, ((modMask c, xK_p), spawn "dmenu_run -l 10 -w 500 -h 30 -fn \"Source Code Pro:size=13\" -p \"> \" -dim 0.5 -o 0.9 -x 710 -y 390 -nb \"#2e3440\" -nf \"#d8dee9\" -sb \"#d8dee9\" -sf \"#2e3440\"") ]
                           , ((modMask c .|. shiftMask, xK_l), spawn "loginctl lock-session")
                           , ((modMask c, xK_p), spawn "rofi -show drun")
                           , ((modMask c, xK_o), spawn "rofi -show window") ]
                           ++ [((modMask c, key), warpToScreen sc (1%2) (1%2))
                           | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]]) <+> keys def

main = do
    xmonad . ewmh . docks $ def
            { borderWidth        = 2
            , terminal           = "alacritty"
            , modMask            = mod4Mask
            , layoutHook         = myLayoutHook
            , handleEventHook    = myEventHook
            , startupHook        = myStartupHook
            , logHook            = myLogHook
            , manageHook         = manageHook def <+> fullscreenManageHook
            , keys               = myKeys
            , normalBorderColor  = "#2e3440"
            , focusedBorderColor = "#657b83" }

setFullscreenSupported :: X ()
setFullscreenSupported = withDisplay $ \dpy -> do
    r <- asks theRoot
    a <- getAtom "_NET_SUPPORTED"
    c <- getAtom "ATOM"
    supp <- mapM getAtom ["_NET_WM_STATE_HIDDEN"
                         ,"_NET_WM_STATE_FULLSCREEN" -- XXX Copy-pasted to add this line
                         ,"_NET_NUMBER_OF_DESKTOPS"
                         ,"_NET_CLIENT_LIST"
                         ,"_NET_CLIENT_LIST_STACKING"
                         ,"_NET_CURRENT_DESKTOP"
                         ,"_NET_DESKTOP_NAMES"
                         ,"_NET_ACTIVE_WINDOW"
                         ,"_NET_WM_DESKTOP"
                         ,"_NET_WM_STRUT"
                         ]
    io $ changeProperty32 dpy r a c propModeReplace (fmap fromIntegral supp)
