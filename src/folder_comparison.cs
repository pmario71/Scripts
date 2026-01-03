#!/usr/local/share/dotnet/dotnet
using System;
using System.IO;

string path1 = @"C:\FolderA";
string path2 = @"C:\FolderB";

if (!Directory.Exists(path1) || !Directory.Exists(path2))
{
    Console.WriteLine("One or both paths do not exist.");
    return -1;
}

Console.WriteLine($"Comparing: {Environment.NewLine}{path1}{Environment.NewLine}{path2}{Environment.NewLine}");

static void CompareFolders(DirectoryInfo dir1, DirectoryInfo dir2)
{
    // 1. Get all relative paths for files and subdirectories
    var files1 = dir1.EnumerateFiles("*", SearchOption.AllDirectories);
    var files2 = dir2.EnumerateFiles("*", SearchOption.AllDirectories);

    // Helper to get relative path from the root directory
    string GetRelativePath(string root, string fullPath) => Path.GetRelativePath(root, fullPath);

    var set1 = files1.ToDictionary(f => GetRelativePath(dir1.FullName, f.FullName));
    var set2 = files2.ToDictionary(f => GetRelativePath(dir2.FullName, f.FullName));

    // 2. Find missing files
    var onlyIn1 = set1.Keys.Except(set2.Keys);
    var onlyIn2 = set2.Keys.Except(set1.Keys);

    Console.WriteLine($"\n-----------------------\n");
    Console.WriteLine($"Files only in {dir1.FullName}:");

    foreach (var file in onlyIn1) Console.WriteLine($"[Missing in B]: {file}");

    Console.WriteLine($"\n-----------------------\n");
    Console.WriteLine($"\nFiles only in {dir2.FullName}:");
    foreach (var file in onlyIn2) Console.WriteLine($"[Missing in A]: {file}");

    Console.WriteLine($"\n-----------------------\n");
    Console.WriteLine($"Files present in both directories with differences:");

    // 3. Compare common files for differences (Size and Last Modified)
    var commonFiles = set1.Keys.Intersect(set2.Keys);
    foreach (var relativePath in commonFiles)
    {
        var f1 = set1[relativePath];
        var f2 = set2[relativePath];

        if (f1.Length != f2.Length)
        {
            Console.WriteLine($"[Different Size]: {relativePath} ({f1.Length} vs {f2.Length} bytes)");
        }
    }
    
    // 4. Compare Directory Structure
    var dirs1 = dir1.GetDirectories("*", SearchOption.AllDirectories).Select(d => GetRelativePath(dir1.FullName, d.FullName));
    var dirs2 = dir2.GetDirectories("*", SearchOption.AllDirectories).Select(d => GetRelativePath(dir2.FullName, d.FullName));

    foreach (var d in dirs1.Except(dirs2)) Console.WriteLine($"[Directory missing in B]: {d}");
    foreach (var d in dirs2.Except(dirs1)) Console.WriteLine($"[Directory missing in A]: {d}");
}

CompareFolders(new DirectoryInfo(path1), new DirectoryInfo(path2));

Console.WriteLine($"\n-----------------------\n");
Console.WriteLine("\nComparison complete.");

return 0;