using Godot;
using System.Runtime.InteropServices;
using System;

public partial class FileAPI : Node
{	
	[DllImport("shell32.dll", CharSet = CharSet.Unicode)]
	private static extern int SHFileOperation([In] ref SHFILEOPSTRUCT lpFileOp);

	[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
	private struct SHFILEOPSTRUCT
	{
		public IntPtr hwnd;
		public uint wFunc;
		public string pFrom;
		public string pTo;
		public ushort fFlags;
		public bool fAnyOperationsAborted;
		public IntPtr hNameMappings;
		public string lpszProgressTitle;
	}

	private const uint FO_DELETE = 0x0003;
	private const ushort FOF_ALLOWUNDO = 0x0040;
	private const ushort FOF_NOCONFIRMATION = 0x0010;

	private void MoveFileToRecycleBin(string filePath)
	{
		var fileOp = new SHFILEOPSTRUCT
		{
			wFunc = FO_DELETE,
			pFrom = filePath + '\0'.ToString(), // Double null termination required
			fFlags = FOF_ALLOWUNDO | FOF_NOCONFIRMATION
		};

		SHFileOperation(ref fileOp);
	}
}
