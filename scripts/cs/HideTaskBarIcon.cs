using Godot;
using System;
using System.Runtime.InteropServices;

public partial class HideTaskBarIcon : Node
{
	[DllImport("user32.dll")]
	private static extern int GetWindowLong(IntPtr hWnd, int nIndex);

	[DllImport("user32.dll")]
	private static extern int SetWindowLong(IntPtr hWnd, int nIndex, int dwNewLong);

	private const int GWL_EXSTYLE = -20;
	private const int WS_EX_APPWINDOW = 0x00040000;
	private const int WS_EX_TOOLWINDOW = 0x00000080;

	public async void HideIcon(int windowId)
	{
		await ToSignal(GetTree().CreateTimer(1), "timeout");
		long windowHandle = DisplayServer.WindowGetNativeHandle(DisplayServer.HandleType.WindowHandle, windowId);
		IntPtr handle = new IntPtr(windowHandle);
		
		int style = GetWindowLong(handle, GWL_EXSTYLE);
		style = style & ~WS_EX_APPWINDOW;
		style = style | WS_EX_TOOLWINDOW;
		SetWindowLong(handle, GWL_EXSTYLE, style);
	}
}
