' ********************************************************************
' ********************************************************************
' **  Roku Custom Video Player Channel (BrightScript)
' **
' **  May 2010
' **  Copyright (c) 2010 Roku Inc. All Rights Reserved.
' ********************************************************************
' ********************************************************************

Sub RunUserInterface()
    UA_Init("UA-XXXXXXX-Y")
    o = Setup()
    UA_trackEvent("App","Load","","")
    o.setup()
    o.paint()
    o.eventloop()
End Sub

Sub Setup() As Object
    this = {
        port:      CreateObject("roMessagePort")
        progress:  0 'buffering progress
        position:  0 'playback position (in seconds)
        paused:    false 'is the video currently paused?
        fonts:     CreateObject("roFontRegistry") 'global font registry
        canvas:    CreateObject("roImageCanvas") 'user interface
        player:    CreateObject("roVideoPlayer")
        setup:     SetupFramedCanvas
        paint:     PaintFramedCanvas
        eventloop: EventLoop
    }

    'Static help text:
    this.help = "Press the right or left arrow buttons on the remote control "
    this.help = this.help + "to seek forward or back through the video at "
    this.help = this.help + "approximately one minute intervals.  Press down "
    this.help = this.help + "to toggle fullscreen."

    'Register available fonts:
    this.fonts.Register("pkg:/fonts/caps.otf")
    this.textcolor = "#406040"

    'Setup image canvas:
    this.canvas.SetMessagePort(this.port)
    this.canvas.SetLayer(0, { Color: "#000000" })
    this.canvas.Show()

    'Resolution-specific settings:
    mode = CreateObject("roDeviceInfo").GetDisplayMode()
    if mode = "720p"
        this.layout = {
            full:   this.canvas.GetCanvasRect()
            top:    { x:   0, y:   0, w:1280, h: 130 }
            left:   { x: 249, y: 177, w: 391, h: 291 }
            right:  { x: 700, y: 177, w: 350, h: 291 }
            bottom: { x: 249, y: 500, w: 780, h: 300 }
        }
        this.background = "pkg:/images/back-hd.jpg"
        this.headerfont = this.fonts.get("lmroman10 caps", 50, 50, false)
    else
        this.layout = {
            full:   this.canvas.GetCanvasRect()
            top:    { x:   0, y:   0, w: 720, h:  80 }
            left:   { x: 100, y: 100, w: 280, h: 210 }
            right:  { x: 400, y: 100, w: 220, h: 210 }
            bottom: { x: 100, y: 340, w: 520, h: 140 }
        }
        this.background = "pkg:/images/back-sd.jpg"
        this.headerfont = this.fonts.get("lmroman10 caps", 30, 50, false)
    end if

    this.player.SetMessagePort(this.port)
    this.player.SetLoop(true)
    this.player.SetPositionNotificationPeriod(1)
    this.player.SetDestinationRect(this.layout.left)
    this.player.SetContentList([{
        Stream: { url: "http://ec2-184-72-239-149.compute-1.amazonaws.com:1935/demos/smil:bigbuckbunnyiphone.smil/playlist.m3u8" }
        StreamFormat: "hls"
        SwitchingStrategy: "full-adaptation"
    }])
    this.player.Play()
    UA_trackPageview("/video_big_buck_bunny")
    return this
End Sub

Sub EventLoop()
    while true
        msg = wait(0, m.port)
        if msg <> invalid
            'If this is a startup progress status message, record progress
            'and update the UI accordingly:
            if msg.isStatusMessage() and msg.GetMessage() = "startup progress"
                m.paused = false
                progress% = msg.GetIndex() / 10
                if m.progress <> progress%
                    m.progress = progress%
                    m.paint()
                end if

            'Playback progress (in seconds):
            else if msg.isPlaybackPosition()
                m.position = msg.GetIndex()
                m.paint()

            'If the <UP> key is pressed, jump out of this context:
            else if msg.isRemoteKeyPressed()
                index = msg.GetIndex()
                print "Remote button pressed: " + index.tostr()
                if index = 2  '<UP>
                    UA_trackEvent("App","Unload","","")
                    return
                else if index = 3 '<DOWN> (toggle fullscreen)
                        UA_trackEvent("Video","FullScreen","","")
                        if m.paint = PaintFullscreenCanvas
                        m.setup = SetupFramedCanvas
                        m.paint = PaintFramedCanvas
                        rect = m.layout.left
                    else
                        m.setup = SetupFullscreenCanvas
                        m.paint = PaintFullscreenCanvas
                        rect = { x:0, y:0, w:0, h:0 } 'fullscreen
                        m.player.SetDestinationRect(0, 0, 0, 0) 'fullscreen
                    end if
                    m.setup()
                    m.player.SetDestinationRect(rect)
                else if index = 4 or index = 8  '<LEFT> or <REV>
                    UA_trackEvent("Video","REV","","60")
                    m.position = m.position - 60
                    m.player.Seek(m.position * 1000)
                else if index = 5 or index = 9  '<RIGHT> or <FWD>
                    UA_trackEvent("Video","FWD","","60")
                    m.position = m.position + 60
                    m.player.Seek(m.position * 1000)
                else if index = 13  '<PAUSE/PLAY>
                    if m.paused m.player.Resume() else m.player.Pause()
                    end if

            else if msg.isPaused()
                UA_trackEvent("Video","Pause","","")
                m.paused = true
                m.paint()

            else if msg.isResumed()
                UA_trackEvent("Video","Resume","","")
                m.paused = false
                m.paint()

            end if
            'Output events for debug
            print msg.GetType(); ","; msg.GetIndex(); ": "; msg.GetMessage()
            if msg.GetInfo() <> invalid print msg.GetInfo();
        end if
    end while
End Sub

Sub SetupFullscreenCanvas()
    m.canvas.AllowUpdates(false)
    m.paint()
    m.canvas.AllowUpdates(true)
End Sub

Sub PaintFullscreenCanvas()
    list = []

    if m.progress < 100
        color = "#000000" 'opaque black
        list.Push({
            Text: "Loading..." + m.progress.tostr() + "%"
            TextAttrs: { font: "huge" }
            TargetRect: m.layout.full
        })
    else if m.paused
        color = "#80000000" 'semi-transparent black
        list.Push({
            Text: "Paused"
            TextAttrs: { font: "huge" }
            TargetRect: m.layout.full
        })
    else
        color = "#00000000" 'fully transparent
    end if

    m.canvas.SetLayer(0, { Color: color, CompositionMode: "Source" })
    m.canvas.SetLayer(1, list)
End Sub

Sub SetupFramedCanvas()
    m.canvas.AllowUpdates(false)
    m.canvas.Clear()
    m.canvas.SetLayer(0, [
        { 'Background:
            Url: m.background
            CompositionMode: "Source"
        },
        { 'The title:
            Text: "Custom Video Player"
            TargetRect: m.layout.top
            TextAttrs: { valign: "bottom", font: m.headerfont, color: m.textcolor }
        },
        { 'Help text:
            Text: m.help
            TargetRect: m.layout.right
            TextAttrs: { halign: "left", valign: "top", color: m.textcolor }
        }
    ])
    m.paint()
    m.canvas.AllowUpdates(true)
End Sub

Sub PaintFramedCanvas()
    list = []
    if m.progress < 100  'Video is currently buffering
        list.Push({
            Color: "#80000000"
            TargetRect: m.layout.left
        })
        list.Push({
            Text: "Loading..." + m.progress.tostr() + "%"
            TargetRect: m.layout.left
        })
    else  'Video is currently playing
        if m.paused
            list.Push({
                Color: "#80000000"
                TargetRect: m.layout.left
                CompositionMode: "Source"
            })
            list.Push({
                Text: "Paused"
                TargetRect: m.layout.left
            })
        else  'not paused
            list.Push({
                Color: "#00000000"
                TargetRect: m.layout.left
                CompositionMode: "Source"
            })
        end if
        list.Push({
            Text: "Current position: " + m.position.tostr() + " seconds"
            TargetRect: m.layout.bottom
            TextAttrs: { halign: "left", valign: "top", color: m.textcolor }
        })
    end if
    m.canvas.SetLayer(1, list)
End Sub
