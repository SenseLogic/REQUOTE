/*
    This file is part of the Requote distribution.

    https://github.com/senselogic/REQUOTE

    Copyright (C) 2026 Eric Pelzer (ecstatic.coder@gmail.com)

    Requote is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3.

    Requote is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Requote.  If not, see <http://www.gnu.org/licenses/>.
*/

// -- IMPORTS

import core.stdc.stdlib : exit;
import std.algorithm : canFind;
import std.conv : to;
import std.file : dirEntries, exists, isFile, mkdirRecurse, readText, write, SpanMode;
import std.path : absolutePath;
import std.stdio : writeln;
import std.string : endsWith, indexOf, join, lastIndexOf, replace, split, startsWith;

// -- FUNCTIONS

void PrintError(
    string message
    )
{
    writeln( "*** ERROR : ", message );
}

// ~~

void Abort(
    string message
    )
{
    PrintError( message );

    exit( -1 );
}

// ~~

void Abort(
    string message,
    Exception exception
    )
{
    PrintError( message );
    PrintError( exception.msg );

    exit( -1 );
}

// ~~

string GetPhysicalPath(
    string path
    )
{
    version( Windows )
    {
        return `\\?\` ~ path.absolutePath.replace( '/', '\\' ).replace( "\\.\\", "\\" );
    }

    return path;
}

// ~~

string GetLogicalPath(
    string path
    )
{
    return path.replace( '\\', '/' );
}

// ~~

string GetFolderPath(
    string file_path
    )
{
    long
        slash_character_index;

    slash_character_index = file_path.lastIndexOf( '/' );

    if ( slash_character_index >= 0 )
    {
        return file_path[ 0 .. slash_character_index + 1 ];
    }
    else
    {
        return "";
    }
}

// ~~

bool IsFolderPath(
    string folder_path
    )
{
    return
        folder_path == ""
        || folder_path.GetLogicalPath().endsWith( '/' );
}

// ~~

string GetFileName(
    string file_path
    )
{
    long
        slash_character_index;

    slash_character_index = file_path.lastIndexOf( '/' );

    if ( slash_character_index >= 0 )
    {
        return file_path[ slash_character_index + 1 .. $ ];
    }
    else
    {
        return file_path;
    }
}

// ~~

string GetFileExtension(
    string file_path
    )
{
    long
        dot_character_index;
    string
        file_name;

    file_name = GetFileName( file_path );
    dot_character_index = file_name.lastIndexOf( '.' );

    if ( dot_character_index >= 0 )
    {
        return file_name[ dot_character_index .. $ ];
    }
    else
    {
        return "";
    }
}

// ~~

bool IsFileExtensionArray(
    string[] file_extension_array
    )
{
    foreach ( file_extension; file_extension_array )
    {
        if ( !file_extension.startsWith( '.' ) )
        {
            return false;
        }
    }

    return true;
}

// ~~

void CreateFolder(
    string folder_path
    )
{
    try
    {
        if ( folder_path != ""
             && folder_path != "/"
             && !folder_path.exists() )
        {
            writeln( "Creating folder : ", folder_path );

            folder_path.GetPhysicalPath().mkdirRecurse();
        }
    }
    catch ( Exception exception )
    {
        Abort( "Can't create folder : " ~ folder_path, exception );
    }
}

// ~~

void WriteText(
    string file_path,
    string file_text
    )
{
    CreateFolder( file_path.GetFolderPath() );

    try
    {
        writeln( "Writing file : ", file_path );

        file_path.write( file_text );
    }
    catch ( Exception exception )
    {
        Abort( "Can't write file : " ~ file_path, exception );
    }
}

// ~~

string ReadText(
    string file_path
    )
{
    string
        file_text;

    writeln( "Reading file : ", file_path );

    try
    {
        file_text = file_path.readText();
    }
    catch ( Exception exception )
    {
        Abort( "Can't read file : " ~ file_path, exception );
    }

    return file_text;
}

// ~~

bool CanRequoteLine(
    string line
    )
{
    long
        character_index;
    char
        character,
        quote_character;

    quote_character = 0;

    for ( character_index = 0;
          character_index < line.length;
          ++character_index )
    {
        character = line[ character_index ];

        if ( quote_character != 0 )
        {
            if ( character == quote_character )
            {
                quote_character = 0;
            }
            else if ( character == '\\' )
            {
                ++character_index;

                if ( character_index < line.length
                     && line[ character_index ] == '(' )
                {
                    return false;
                }
            }
            else if ( character == '$'
                      || character == '{'
                      || character == '}' )
            {
                return false;
            }
        }
        else if ( character == '\''
                  || character == '"'
                  || character == '`' )
        {
            quote_character = character;
        }
        else if ( character == '/' )
        {
            return false;
        }
    }

    return quote_character == 0;
}

// ~~

void RequoteFile(
    string input_file_path,
    string output_file_path,
    char old_quote_character,
    char new_quote_character
    )
{
    char
        character,
        quote_character;
    char[]
        character_array;
    long
        character_index,
        first_old_quote_character_index,
        last_old_quote_character_index,
        line_index;
    string
        input_file_text,
        line,
        output_file_text;
    string[]
        line_array;

    input_file_text = input_file_path.ReadText();
    line_array = input_file_text.replace( "\r", "" ).split( "\n" );

    for ( line_index = 0;
          line_index < line_array.length;
          ++line_index )
    {
        line = line_array[ line_index ];

        first_old_quote_character_index = line.indexOf( old_quote_character );
        last_old_quote_character_index = line.lastIndexOf( old_quote_character );

        if ( first_old_quote_character_index >= 0
             && first_old_quote_character_index < last_old_quote_character_index
             && line.CanRequoteLine() )
        {
            character_array = line.to!(char[])();
            quote_character = 0;

            for ( character_index = 0;
                  character_index < character_array.length;
                  ++character_index )
            {
                character = character_array[ character_index ];

                if ( quote_character != 0 )
                {
                    if ( character == quote_character )
                    {
                        if ( quote_character == old_quote_character )
                        {
                            character_array[ character_index ] = new_quote_character;
                        }

                        quote_character = 0;
                    }
                    else if ( character == '\\' )
                    {
                        if ( quote_character == old_quote_character
                             && character_index + 1 < character_array.length
                             && character_array[ character_index + 1 ] == old_quote_character )
                        {
                            character_array
                                = character_array[ 0 .. character_index ]
                                  ~ character_array[ character_index + 1 .. $ ];
                        }
                        else
                        {
                            ++character_index;
                        }
                    }
                    else if ( quote_character == old_quote_character
                              && character == new_quote_character )
                    {
                        character_array
                            = character_array[ 0 .. character_index ]
                              ~ '\\'
                              ~ character_array[ character_index .. $ ];

                        ++character_index;
                    }
                }
                else if ( character == '\''
                          || character == '"'
                          || character == '`' )
                {
                    quote_character = character;

                    if ( quote_character == old_quote_character )
                    {
                        character_array[ character_index ] = new_quote_character;
                    }
                }
            }

            line_array[ line_index ] = character_array.to!string();
        }
    }

    output_file_text = line_array.join( "\n" );

    if ( output_file_text != input_file_text )
    {
        output_file_path.WriteText( output_file_text );
    }
}

// ~~

void RequoteFiles(
    string input_folder_path,
    string output_folder_path,
    string[] file_extension_array,
    char old_quote_character,
    char new_quote_character,
    )
{
    string
        input_file_extension,
        input_file_path,
        output_file_path;

    writeln( "Reading folder : ", input_folder_path );

    foreach ( input_folder_entry; input_folder_path.dirEntries( SpanMode.depth ) )
    {
        if ( input_folder_entry.isFile )
        {
            input_file_path = input_folder_entry.name.GetLogicalPath();
            input_file_extension = input_file_path.GetFileExtension();

            if ( input_file_path.startsWith( input_folder_path )
                 && file_extension_array.canFind( input_file_extension ) )
            {
                output_file_path = output_folder_path ~ input_file_path[ input_folder_path.length .. $ ];

                RequoteFile(
                    input_file_path,
                    output_file_path,
                    old_quote_character,
                    new_quote_character
                    );
            }
        }
    }
}

// ~~

int main(
    string[] argument_array
    )
{
    argument_array = argument_array[ 1 .. $ ];

    if ( argument_array.length >= 4
         && ( argument_array[ 0 ] == "--single"
              || argument_array[ 0 ] == "--double" )
         && argument_array[ 1 ].IsFolderPath()
         && argument_array[ 2 ].IsFolderPath()
         && argument_array[ 3 .. $ ].IsFileExtensionArray() )
    {
        RequoteFiles(
            argument_array[ 1 ].GetLogicalPath(),
            argument_array[ 2 ].GetLogicalPath(),
            argument_array[ 3 .. $ ],
            argument_array[ 0 ] == "--single" ? '"' : '\'',
            argument_array[ 0 ] == "--single" ? '\'' : '"'
            );
    }
    else
    {
        writeln( "Usage :" );
        writeln( "    requote --single <input folder path> <output folder path> <file extension> [<file extension> ...]" );
        writeln( "    requote --double <input folder path> <output folder path> <file extension> [<file extension> ...]" );

        PrintError( "Invalid arguments : " ~ argument_array.to!string() );
    }

    return 0;
}
