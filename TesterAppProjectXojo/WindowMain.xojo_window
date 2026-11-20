#tag DesktopWindow
Begin DesktopWindow WindowMain
   Backdrop        =   0
   BackgroundColor =   &cFFFFFF
   Composite       =   False
   DefaultLocation =   2
   FullScreen      =   False
   HasBackgroundColor=   False
   HasCloseButton  =   True
   HasFullScreenButton=   True
   HasMaximizeButton=   True
   HasMinimizeButton=   True
   Height          =   504
   ImplicitInstance=   False
   MacProcID       =   0
   MaximumHeight   =   32000
   MaximumWidth    =   32000
   MenuBar         =   523120639
   MenuBarVisible  =   False
   MinimumHeight   =   64
   MinimumWidth    =   64
   Resizeable      =   True
   Title           =   "FSEvents Shell Tester"
   Type            =   0
   Visible         =   True
   Width           =   988
   Begin Shell ShellFSEvents
      Arguments       =   ""
      Backend         =   ""
      Canonical       =   False
      ExecuteMode     =   0
      ExitCode        =   0
      Index           =   -2147483648
      IsRunning       =   False
      LockedInPosition=   False
      PID             =   0
      Result          =   ""
      Scope           =   2
      TabPanelIndex   =   0
      TimeOut         =   0
   End
   Begin DesktopTextArea TextAreaLog
      AllowAutoDeactivate=   True
      AllowFocusRing  =   True
      AllowSpellChecking=   True
      AllowStyledText =   True
      AllowTabs       =   False
      BackgroundColor =   &cFFFFFF
      Bold            =   False
      Enabled         =   True
      FontName        =   "SmallSystem"
      FontSize        =   0.0
      FontUnit        =   0
      Format          =   ""
      HasBorder       =   True
      HasHorizontalScrollbar=   False
      HasVerticalScrollbar=   True
      Height          =   154
      HideSelection   =   True
      Index           =   -2147483648
      Italic          =   False
      Left            =   20
      LineHeight      =   0.0
      LineSpacing     =   1.0
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   False
      MaximumCharactersAllowed=   0
      Multiline       =   True
      ReadOnly        =   True
      Scope           =   2
      TabIndex        =   0
      TabPanelIndex   =   0
      TabStop         =   True
      Text            =   ""
      TextAlignment   =   0
      TextColor       =   &c000000
      Tooltip         =   ""
      Top             =   330
      Transparent     =   False
      Underline       =   False
      UnicodeMode     =   1
      ValidationMask  =   ""
      Visible         =   True
      Width           =   948
   End
   Begin DesktopListBox ListBoxLog
      AllowAutoDeactivate=   True
      AllowAutoHideScrollbars=   True
      AllowExpandableRows=   False
      AllowFocusRing  =   True
      AllowResizableColumns=   False
      AllowRowDragging=   False
      AllowRowReordering=   False
      Bold            =   False
      ColumnCount     =   2
      ColumnWidths    =   "70%,30%"
      DefaultRowHeight=   -1
      DropIndicatorVisible=   False
      Enabled         =   True
      FontName        =   "SmallSystem"
      FontSize        =   0.0
      FontUnit        =   0
      GridLineStyle   =   0
      HasBorder       =   True
      HasHeader       =   True
      HasHorizontalScrollbar=   False
      HasVerticalScrollbar=   True
      HeadingIndex    =   -1
      Height          =   298
      Index           =   -2147483648
      InitialValue    =   "File	Flags"
      Italic          =   False
      Left            =   20
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   True
      RequiresSelection=   False
      RowSelectionType=   0
      Scope           =   2
      TabIndex        =   1
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   ""
      Top             =   20
      Transparent     =   False
      Underline       =   False
      Visible         =   True
      Width           =   948
      _ScrollOffset   =   0
      _ScrollWidth    =   -1
   End
End
#tag EndDesktopWindow

#tag WindowCode
	#tag MenuHandler
		Function FileClose() As Boolean Handles FileClose.Action
		  self.ShellFSEvents.Close()
		  
		  self.Close()
		  
		  return true
		  
		  
		End Function
	#tag EndMenuHandler


	#tag Method, Flags = &h0
		Sub Constructor(f as FolderItem)
		  super.Constructor()
		  
		  self.Title = f.NativePath
		  
		  self.ShellFSEvents.ExecuteMode = Shell.ExecuteModes.Asynchronous
		  
		  var binary as FolderItem = SpecialFolder.Resources.Child( "FSEvents" )
		  
		  self.ShellFSEvents.Execute( binary.ShellPath + " " + f.ShellPath )
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub processLine(line as String)
		  if line = "" then return
		  
		  try
		    
		    var json as JSONItem = new JSONItem( line )
		    
		    var path as String = json.Value( "path" )
		    
		    
		    // var id as UInt64 = json.Value( "id" )
		    
		    var id as String = json.Value( "id" )
		    
		    var id_UInt64 as UInt64 = UInt64.FromString( id )
		    
		    // System.DebugLog( id + " " + id_UInt64.ToString() )
		    
		    #pragma unused id_UInt64
		    
		    
		    var flags as JSONItem = json.Value( "flags" )
		    
		    var keys() as String = flags.Keys()
		    
		    var flagsAsString as String = String.fromArray( keys, ", " )
		    
		    self.ListBoxLog.AddRow( path, flagsAsString )
		    
		    self.ListBoxLog.ScrollPosition = 1000000
		    
		  catch e as JSONException
		    
		    // do nothing, this is expected
		    // some output from FSEvents binary is not JSON
		    
		    self.TextAreaLog.AddText( line + EndOfLine() )
		    
		    self.TextAreaLog.VerticalScrollPosition = 1000000
		    
		  end try
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function startNewSessionFor(f as FolderItem) As WindowMain
		  var w as WindowMain = new WindowMain( f )
		  
		  return w
		  
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private data As String
	#tag EndProperty


#tag EndWindowCode

#tag Events ShellFSEvents
	#tag Event
		Sub DataAvailable()
		  // can't count on incoming data being "neatly" chunked into lines
		  // so have to accumulate it with whatever was left from last time,
		  // then start going through it from beginning looking for breaks
		  // leaving whatever is left at the end for the next time around
		  
		  var data as String = me.ReadAll()
		  
		  self.data = self.data + data
		  
		  var eolPos as Integer = 0
		  
		  var eolLength as Integer = EndOfLine().Native.Length()
		  
		  while true
		    
		    eolPos = self.data.IndexOf( EndOfLine().Native )
		    
		    if eolPos = -1 then exit
		    
		    var line as String = self.data.Left( eolPos )
		    
		    self.data = self.data.Middle( eolPos + eolLength )
		    
		    self.processLine( line )
		    
		  wend
		  
		  
		End Sub
	#tag EndEvent
	#tag Event
		Sub Completed()
		  // I think there can still be final incoming data from shell app?
		  
		  var data as String = me.ReadAll()
		  
		  self.data = self.data + data
		  
		  var eolPos as Integer = 0
		  
		  var eolLength as Integer = EndOfLine().Native.Length()
		  
		  while true
		    
		    eolPos = self.data.IndexOf( EndOfLine().Native )
		    
		    if eolPos = -1 then exit
		    
		    var line as String = self.data.Left( eolPos )
		    
		    self.data = self.data.Middle( eolPos + eolLength )
		    
		    self.processLine( line )
		    
		  wend
		  
		  // and there might be a final line with no EndOfLine after it?
		  
		  if self.data <> "" then
		    
		    self.processLine( self.data )
		    
		    self.data = ""
		    
		  end if
		  
		  
		End Sub
	#tag EndEvent
#tag EndEvents
#tag ViewBehavior
	#tag ViewProperty
		Name="Name"
		Visible=true
		Group="ID"
		InitialValue=""
		Type="String"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Interfaces"
		Visible=true
		Group="ID"
		InitialValue=""
		Type="String"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Super"
		Visible=true
		Group="ID"
		InitialValue=""
		Type="String"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Width"
		Visible=true
		Group="Size"
		InitialValue="600"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Height"
		Visible=true
		Group="Size"
		InitialValue="400"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MinimumWidth"
		Visible=true
		Group="Size"
		InitialValue="64"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MinimumHeight"
		Visible=true
		Group="Size"
		InitialValue="64"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MaximumWidth"
		Visible=true
		Group="Size"
		InitialValue="32000"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MaximumHeight"
		Visible=true
		Group="Size"
		InitialValue="32000"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Type"
		Visible=true
		Group="Frame"
		InitialValue="0"
		Type="Types"
		EditorType="Enum"
		#tag EnumValues
			"0 - Document"
			"1 - Movable Modal"
			"2 - Modal Dialog"
			"3 - Floating Window"
			"4 - Plain Box"
			"5 - Shadowed Box"
			"6 - Rounded Window"
			"7 - Global Floating Window"
			"8 - Sheet Window"
			"9 - Metal Window"
			"11 - Modeless Dialog"
		#tag EndEnumValues
	#tag EndViewProperty
	#tag ViewProperty
		Name="Title"
		Visible=true
		Group="Frame"
		InitialValue="Untitled"
		Type="String"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="HasCloseButton"
		Visible=true
		Group="Frame"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="HasMaximizeButton"
		Visible=true
		Group="Frame"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="HasMinimizeButton"
		Visible=true
		Group="Frame"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="HasFullScreenButton"
		Visible=true
		Group="Frame"
		InitialValue="False"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Resizeable"
		Visible=true
		Group="Frame"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Composite"
		Visible=false
		Group="OS X (Carbon)"
		InitialValue="False"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MacProcID"
		Visible=false
		Group="OS X (Carbon)"
		InitialValue="0"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="FullScreen"
		Visible=true
		Group="Behavior"
		InitialValue="False"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="DefaultLocation"
		Visible=true
		Group="Behavior"
		InitialValue="2"
		Type="Locations"
		EditorType="Enum"
		#tag EnumValues
			"0 - Default"
			"1 - Parent Window"
			"2 - Main Screen"
			"3 - Parent Window Screen"
			"4 - Stagger"
		#tag EndEnumValues
	#tag EndViewProperty
	#tag ViewProperty
		Name="Visible"
		Visible=true
		Group="Behavior"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="ImplicitInstance"
		Visible=true
		Group="Window Behavior"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="HasBackgroundColor"
		Visible=true
		Group="Background"
		InitialValue="False"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="BackgroundColor"
		Visible=true
		Group="Background"
		InitialValue="&cFFFFFF"
		Type="ColorGroup"
		EditorType="ColorGroup"
	#tag EndViewProperty
	#tag ViewProperty
		Name="Backdrop"
		Visible=true
		Group="Background"
		InitialValue=""
		Type="Picture"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MenuBar"
		Visible=true
		Group="Menus"
		InitialValue=""
		Type="DesktopMenuBar"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MenuBarVisible"
		Visible=true
		Group="Deprecated"
		InitialValue="False"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
#tag EndViewBehavior
