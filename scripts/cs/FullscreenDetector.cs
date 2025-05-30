using Godot;
using System;
using System.Runtime.InteropServices;

public partial class FullscreenDetector : Node
{
	[DllImport("user32.dll")]
	private static extern IntPtr GetForegroundWindow();

	[DllImport("user32.dll")]
	[return: MarshalAs(UnmanagedType.Bool)]
	private static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

	private struct RECT
	{
		public int Left;
		public int Top;
		public int Right;
		public int Bottom;
	}
	
	public bool IsOtherAppFullscreen()
	{
		IntPtr hWnd = GetForegroundWindow();
		RECT rect;
		if (hWnd != IntPtr.Zero && GetWindowRect(hWnd, out rect))
		{
			int windowWidth = rect.Right - rect.Left;
			int windowHeight = rect.Bottom - rect.Top;
			
			Godot.Vector2I screenSize = DisplayServer.ScreenGetSize();

			return windowWidth == screenSize.X && windowHeight == screenSize.Y;
		}
		else
		{
			return false;
		}
	}
}
