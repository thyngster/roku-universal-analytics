' ********************************************************************
' ********************************************************************
' **
' **  Roku Universal Analytics Tracking Library (BrightScript)' **
' **  v. 0.1
' **
' **  @author David Vallejo <thyngster@gmail.com> ( @thyng )
' **  Copyright 2013
' **
' ********************************************************************
' ********************************************************************

Function GenerateGuid() As String
    Return "" + GetRandomHexString(8) + "-" + GetRandomHexString(4) + "-" + GetRandomHexString(4) + "-" + GetRandomHexString(4) + "-" + GetRandomHexString(12) + ""
End Function

Function GetRandomHexString(length As Integer) As String
    hexChars = "0123456789ABCDEF"
    hexString = ""
    For i = 1 to length
        hexString = hexString + hexChars.Mid(Rnd(16) - 1, 1)
    Next
    Return hexString
End Function

Function GetRandomInt(length As Integer) As String
    hexChars = "0123456789"
    hexString = ""
    For i = 1 to length
        hexString = hexString + hexChars.Mid(Rnd(16) - 1, 1)
    Next
    Return hexString
End Function

Function GetUserID() As String
    sec = CreateObject("roRegistrySection", "analytics")
    if sec.Exists("UserID")
        return sec.Read("UserID")
    endif
    return invalid
End Function

Function SetUserID() As String
    sec = CreateObject("roRegistrySection", "analytics")
    uuid = GenerateGuid()
    sec.Write("UserID", uuid)
    sec.Flush()
    Return uuid
End Function

Function UA_Init(AccountID as String) as Void
    di = CreateObject("roDeviceInfo") 
    m.UATracker = CreateObject("roAssociativeArray")

    m.UATracker.userID = GetUserID()
    m.UATracker.AccountID = AccountID

    if m.UATracker.userID = invalid then
        m.UATracker.userID = SetUserID()
    endif

    m.UATracker.model = di.GetModel()
    m.UATracker.version = di.GetVersion()    
    
    'dimensiones = di.GetDisplaySize()
    'm.UATracker.display = dimensiones.w + "x" + dimensiones.h

    if di.GetDisplayMode() = "480i"
    m.UATracker.display = "704x480"
    elseif di.GetDisplayMode() = "720p"
    m.UATracker.display = "1280x720"
    else
    m.UATracker.display = "0x0"
    end if

    m.UATracker.appName = "Test_APP"
    m.UATracker.appVersion = "b1"

    m.UATracker.ratio = di.GetDisplayAspectRatio()
    m.UATracker.endpoint = "http://www.analytics-debugger.com/universal/"
    'm.UATracker.endpoint = "http://www.google-analytics.com/collect?"
End Function

Function UA_trackEvent(EventCat as String , EventAct as String , EventLab as String , EventVal as String) as Void

    payload = "z="+GetRandomInt(10)
    payload = payload + "&v=1"
    payload = payload + "&cid=" + m.UATracker.userID
    payload = payload + "&tid=" + m.UATracker.AccountID   
    payload = payload + "&dimension1=" + m.UATracker.model
    payload = payload + "&dimension2=" + m.UATracker.version
    payload = payload + "&sr=" + m.UATracker.display     
    payload = payload + "&sd=" + m.UATracker.ratio
    payload = payload + "&an=" + m.UATracker.appName
    payload = payload + "&av=" + m.UATracker.appVersion    

    payload = payload + "&t=event" 
    If Len(EventCat) > 0
    payload = payload + "&ec=" + EventCat
    end if
    If Len(EventAct) > 0
    payload = payload + "&ea=" + EventAct
    end if
    If Len(EventLab) > 0
    payload = payload + "&el=" + EventLab
    end if
    If Len(EventVal) > 0
    payload = payload + "&ev=" + EventVal
    end if

    xfer = CreateObject("roURLTransfer")
    xfer.SetURL(m.UATracker.endpoint+"?"+payload)
    response = xfer.GetToString()    
End Function

Function UA_trackPageview(Pageview as String) as Void

    payload = "z="+GetRandomInt(10)
    payload = payload + "&v=1"
    payload = payload + "&cid=" + m.UATracker.userID
    payload = payload + "&tid=" + m.UATracker.AccountID   
    payload = payload + "&dimension1=" + m.UATracker.model
    payload = payload + "&dimension2=" + m.UATracker.version
    payload = payload + "&sr=" + m.UATracker.display     
    payload = payload + "&sd=" + m.UATracker.ratio
    payload = payload + "&an=" + m.UATracker.appName
    payload = payload + "&av=" + m.UATracker.appVersion    
    payload = payload + "&t=pageview" 

    If Len(Pageview) > 0
    payload = payload + "&dp=" + Pageview
    end if

    xfer = CreateObject("roURLTransfer")
    xfer.SetURL(m.UATracker.endpoint+"?"+payload)    
    response = xfer.GetToString()    
End Function
