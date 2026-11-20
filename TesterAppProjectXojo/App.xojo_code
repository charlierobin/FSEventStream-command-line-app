#tag Class
Protected Class App
Inherits DesktopApplication
	#tag MenuHandler
		Function FileDesktop() As Boolean Handles FileDesktop.Action
		  call WindowMain.startNewSessionFor( SpecialFolder.Desktop )
		  
		  return true
		  
		End Function
	#tag EndMenuHandler

	#tag MenuHandler
		Function FileNew() As Boolean Handles FileNew.Action
		  var f as FolderItem = FolderItem.ShowSelectFolderDialog()
		  
		  if f <> nil then
		    
		    call WindowMain.startNewSessionFor( f )
		    
		  end if
		  
		  return true
		  
		End Function
	#tag EndMenuHandler


	#tag Constant, Name = kEditClear, Type = String, Dynamic = False, Default = \"&Delete", Scope = Public
		#Tag Instance, Platform = Windows, Language = Default, Definition  = \"&Delete"
		#Tag Instance, Platform = Linux, Language = Default, Definition  = \"&Delete"
	#tag EndConstant

	#tag Constant, Name = kFileQuit, Type = String, Dynamic = False, Default = \"&Quit", Scope = Public
		#Tag Instance, Platform = Windows, Language = Default, Definition  = \"E&xit"
	#tag EndConstant

	#tag Constant, Name = kFileQuitShortcut, Type = String, Dynamic = False, Default = \"", Scope = Public
		#Tag Instance, Platform = Mac OS, Language = Default, Definition  = \"Cmd+Q"
		#Tag Instance, Platform = Linux, Language = Default, Definition  = \"Ctrl+Q"
	#tag EndConstant


End Class
#tag EndClass
