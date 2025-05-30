using Godot;
using System;
using System.Runtime.InteropServices;

public partial class MouseTracker : Node
{
	// 定义 POINT 结构体（用于接收系统坐标）
	[StructLayout(LayoutKind.Sequential)]
	public struct POINT
	{
		public int X;
		public int Y;
	}

	// 导入 Windows API 函数
	[DllImport("user32.dll")]
	[return: MarshalAs(UnmanagedType.Bool)]
	public static extern bool GetCursorPos(out POINT lpPoint);
	
	[DllImport("user32.dll")]
	public static extern int GetSystemMetrics(int nIndex);
	
	public Vector2I GetMousePosition()
	{
		if (GetCursorPos(out POINT point))
		{
			return new Vector2I(point.X, point.Y);
		}
		else
		{
			return Vector2I.Zero;
		}
	}
	
	public Vector2I GetMousePositionGlobal()
	{
		if (GetCursorPos(out POINT point))
		{
			int screenLeft = GetSystemMetrics(76); // SM_XVIRTUALSCREEN 获取虚拟屏幕的最左侧坐标
			int screenTop = GetSystemMetrics(77);  // SM_YVIRTUALSCREEN 获取虚拟屏幕的最顶部坐标
			return new Vector2I(point.X - screenLeft, point.Y - screenTop);
		}
		else
		{
			return Vector2I.Zero;
		}
	}
}
