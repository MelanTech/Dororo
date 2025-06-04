using System;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;
using Godot;
using System.Reflection;

public partial class AutoStarter : Node
{
	[ComImport]
	[Guid("000214F9-0000-0000-C000-000000000046")]
	[InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
	private interface IShellLinkW
	{
		[PreserveSig] int GetPath(
			[Out, MarshalAs(UnmanagedType.LPWStr)] StringBuilder pszFile,
			int cchMaxPath, IntPtr pfd, uint fFlags);
		
		[PreserveSig] int GetIDList(out IntPtr ppidl);
		[PreserveSig] int SetIDList(IntPtr pidl);
		
		[PreserveSig] int GetDescription(
			[Out, MarshalAs(UnmanagedType.LPWStr)] StringBuilder pszName,
			int cchMaxName);
			
		[PreserveSig] int SetDescription(
			[MarshalAs(UnmanagedType.LPWStr)] string pszName);
			
		[PreserveSig] int GetWorkingDirectory(
			[Out, MarshalAs(UnmanagedType.LPWStr)] StringBuilder pszDir,
			int cchMaxPath);
			
		[PreserveSig] int SetWorkingDirectory(
			[MarshalAs(UnmanagedType.LPWStr)] string pszDir);
			
		[PreserveSig] int GetArguments(
			[Out, MarshalAs(UnmanagedType.LPWStr)] StringBuilder pszArgs,
			int cchMaxPath);
			
		[PreserveSig] int SetArguments(
			[MarshalAs(UnmanagedType.LPWStr)] string pszArgs);
			
		[PreserveSig] int GetHotkey(out short pwHotkey);
		[PreserveSig] int SetHotkey(short wHotkey);
		[PreserveSig] int GetShowCmd(out int piShowCmd);
		[PreserveSig] int SetShowCmd(int iShowCmd);
		
		[PreserveSig] int GetIconLocation(
			[Out, MarshalAs(UnmanagedType.LPWStr)] StringBuilder pszIconPath,
			int cchIconPath, out int piIcon);
			
		[PreserveSig] int SetIconLocation(
			[MarshalAs(UnmanagedType.LPWStr)] string pszIconPath, int iIcon);
			
		[PreserveSig] int SetRelativePath(
			[MarshalAs(UnmanagedType.LPWStr)] string pszPathRel, uint dwReserved);
			
		[PreserveSig] int Resolve(IntPtr hwnd, uint fFlags);
		[PreserveSig] int SetPath(
			[MarshalAs(UnmanagedType.LPWStr)] string pszFile);
	}

	[ComImport]
	[Guid("0000010b-0000-0000-C000-000000000046")]
	[InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
	private interface IPersistFile
	{
		void GetClassID(out Guid pClassID);
		[PreserveSig]
		int IsDirty();
		void Load([MarshalAs(UnmanagedType.LPWStr)] string pszFileName, uint dwMode);
		void Save([MarshalAs(UnmanagedType.LPWStr)] string pszFileName, bool fRemember);
		void SaveCompleted([MarshalAs(UnmanagedType.LPWStr)] string pszFileName);
		void GetCurFile([MarshalAs(UnmanagedType.LPWStr)] out string ppszFileName);
	}

	[DllImport("shell32.dll", CharSet = CharSet.Unicode)]
	private static extern int SHGetKnownFolderPath([MarshalAs(UnmanagedType.LPStruct)] Guid rfid, uint dwFlags, IntPtr hToken, out string ppszPath);

	private static readonly Guid FOLDERID_Startup = new Guid("{B97D20BB-F46A-4C97-BA10-5E3608430854}");

	public static void EnableAutoStart(string appName)
	{
		string startupPath = GetStartupFolderPath();
		if (string.IsNullOrEmpty(startupPath)) return;

		string shortcutPath = Path.Combine(startupPath, appName + ".lnk");
		string exePath = System.Diagnostics.Process.GetCurrentProcess().MainModule.FileName;

		CreateShortcut(shortcutPath, exePath);
	}

	public static void DisableAutoStart(string appName)
	{
		string startupPath = GetStartupFolderPath();
		if (string.IsNullOrEmpty(startupPath)) return;

		string shortcutPath = Path.Combine(startupPath, appName + ".lnk");
		if (File.Exists(shortcutPath))
		{
			File.Delete(shortcutPath);
		}
	}

	public static bool IsAutoStartEnabled(string appName)
	{
		string startupPath = GetStartupFolderPath();
		if (string.IsNullOrEmpty(startupPath)) return false;

		string shortcutPath = Path.Combine(startupPath, appName + ".lnk");
		return File.Exists(shortcutPath);
	}

	private static string GetStartupFolderPath()
	{
		string path;
		int result = SHGetKnownFolderPath(FOLDERID_Startup, 0, IntPtr.Zero, out path);
		return result >= 0 ? path : null;
	}

	private static void CreateShortcut(string shortcutPath, string targetPath)
	{
		CoInitializeEx(IntPtr.Zero, COINIT.COINIT_APARTMENTTHREADED);
		
		try {
			// 使用Type.GetTypeFromProgID更可靠
			Type shellLinkType = Type.GetTypeFromProgID("WScript.Shell");
			object shell = Activator.CreateInstance(shellLinkType);
			
			// 通过IDispatch调用避免直接转换
			dynamic shellLink = shell.GetType().InvokeMember(
				"CreateShortcut", 
				BindingFlags.InvokeMethod, 
				null, 
				shell, 
				new object[] { shortcutPath });
			
			shellLink.TargetPath = targetPath;
			
			string workingDirectory = Path.GetDirectoryName(targetPath);
			if (!string.IsNullOrEmpty(workingDirectory))
			{
				shellLink.WorkingDirectory = workingDirectory;
			}
			
			shellLink.Save();
		}
		finally {
			CoUninitialize();
		}
	}
	
	// COM初始化API
	[DllImport("ole32.dll")]
	private static extern int CoInitializeEx(IntPtr pvReserved, COINIT dwCoInit);
	
	[DllImport("ole32.dll")]
	private static extern void CoUninitialize();
	
	private enum COINIT : uint
	{
		COINIT_APARTMENTTHREADED = 0x2,
		COINIT_MULTITHREADED = 0x0
	}
}
