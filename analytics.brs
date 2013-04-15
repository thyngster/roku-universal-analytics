' Universal Analytics Tracking Library for Roku
' 2013 . David Vallejo (@thyng)
' http://www.thyngster.com

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

Function SendHit(PayLoad as String)

End Function
Function UA_Init(AccountID as String) as Void
    di = CreateObject("roDeviceInfo") 
    m.UATracker = CreateObject("roAssociativeArray")

    m.UATracker.userID = GetUserID()
    m.UATracker.AccountID = AccountID

    if m.UATracker.userID = invalid then
        m.UATracker.userID = SetUserID()
    endif

'    Tracker = CreateObject("roAssociativeArray") 
'    Tracker.Resolution = di.GetDisplayMode() + " " + di.GetDisplayType() 
'    Tracker.UA = AccountID 
     payload = "z="+GetRandomInt(10)
     payload = payload + "&cid=" + m.UATracker.userID
     payload = payload + "&tid=" + m.UATracker.AccountID     
    xfer = CreateObject("roURLTransfer")
    xfer.SetURL("http://www.analytics-debugger.com/universal/?"+payload)
    response = xfer.GetToString()    
End Function

Function UA_trackEvent(EventCat as String,EventAct as String, EventLab as String, EventVal as Integer) as Void
    payload = "z="+GetRandomInt(10)
    payload = payload + "&cid=" + m.UATracker.userID
    payload = payload + "&tid=" + m.UATracker.AccountID     
    xfer = CreateObject("roURLTransfer")
    xfer.SetURL("http://www.analytics-debugger.com/universal/?"+payload)
    response = xfer.GetToString()    
End Function

Function UA_trackPageview(PageUrl as String) as Void
    payload = "z="+GetRandomInt(10)
    payload = payload + "&cid=" + m.UATracker.userID
    payload = payload + "&tid=" + m.UATracker.AccountID     
    xfer = CreateObject("roURLTransfer")
    xfer.SetURL("http://www.analytics-debugger.com/universal/?"+payload)
    response = xfer.GetToString()    
End Function

Function UA_trackTiming(EventCat as String,EventAct as String, EventLab as String, EventVal as Integer) as Void
    payload = "z="+GetRandomInt(10)
    payload = payload + "&cid=" + m.UATracker.userID
    payload = payload + "&tid=" + m.UATracker.AccountID     
    xfer = CreateObject("roURLTransfer")
    xfer.SetURL("http://www.analytics-debugger.com/universal/?"+payload)
    response = xfer.GetToString()    
End Function

Function UA_send() as Void
    payload = "z="+GetRandomInt(10)
    payload = payload + "&cid=" + m.UATracker.userID
    payload = payload + "&tid=" + m.UATracker.AccountID     
    xfer = CreateObject("roURLTransfer")
    xfer.SetURL("http://www.analytics-debugger.com/universal/?"+payload)
    response = xfer.GetToString()    
End Function

Function UA_setCustomDimension() as Void

End Function


Function UA_setCustomMetric() as Void


End Function
