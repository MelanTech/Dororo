using Godot;
using System;
using System.Runtime.InteropServices;

public partial class WindowManager : Node
{
	// Windows API 导入
	[DllImport("user32.dll")]
	private static extern IntPtr GetActiveWindow();
	
	[DllImport("user32.dll")]
	private static extern int SetWindowLong(IntPtr hWnd, int nIndex, int dwNewLong); // 修改为int参数
	
	[DllImport("user32.dll")]
	private static extern int GetWindowLong(IntPtr hWnd, int nIndex);
	
	[DllImport("user32.dll")]
	private static extern IntPtr GetForegroundWindow();

	[DllImport("user32.dll")]
	[return: MarshalAs(UnmanagedType.Bool)]
	private static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
	
	[DllImport("user32.dll")]
	private static extern int GetSystemMetrics(int nIndex);

	private struct RECT
	{
		public int Left;
		public int Top;
		public int Right;
		public int Bottom;
	}
	
	// 常量定义
	private const int GwlExStyle = -20;
	
	// 点击穿透相关样式
	private const uint WsExLayered = 0x00080000;
	private const uint WsExTransparent = 0x00000020;
	
	// 任务栏图标相关样式
	private const int WS_EX_APPWINDOW = 0x00040000;
	private const int WS_EX_TOOLWINDOW = 0x00000080;
	
	private IntPtr _hWnd;

	public override void _Ready()
	{
		_hWnd = GetActiveWindow();
		InitializeWindowStyle();
	}

	private void InitializeWindowStyle()
	{
		int currentStyle = GetWindowLong(_hWnd, GwlExStyle);
		int newStyle = currentStyle | (int)WsExLayered; // 显式转换为int
		SetWindowLong(_hWnd, GwlExStyle, newStyle);
	}

	public void SetClickThrough(bool clickthrough)
	{
		if (_hWnd == IntPtr.Zero) return;
		
		int currentStyle = GetWindowLong(_hWnd, GwlExStyle);
		
		currentStyle = currentStyle & ~((int)WsExLayered | (int)WsExTransparent); // 显式转换为int
		
		if (clickthrough)
		{
			currentStyle = currentStyle | (int)(WsExLayered | WsExTransparent); // 显式转换为int
		}
		else
		{
			currentStyle = currentStyle | (int)WsExLayered; // 显式转换为int
		}
		
		currentStyle = currentStyle | WS_EX_TOOLWINDOW;
		currentStyle = currentStyle & ~WS_EX_APPWINDOW;
		
		SetWindowLong(_hWnd, GwlExStyle, currentStyle); // 使用int参数
	}

	public void HideTaskbarIcon()
	{
		if (_hWnd == IntPtr.Zero) return;
		
		int currentStyle = GetWindowLong(_hWnd, GwlExStyle);
		
		currentStyle = currentStyle & ~WS_EX_APPWINDOW;
		currentStyle = currentStyle | WS_EX_TOOLWINDOW;
		
		SetWindowLong(_hWnd, GwlExStyle, currentStyle); // 使用int参数
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
