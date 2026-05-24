![](https://github.com/senselogic/REQUOTE/blob/master/LOGO/requote.png)

# Requote

Simple quote converter.

## Installation

Install the [DMD 2 compiler](https://dlang.org/download.html) (using the MinGW setup option on Windows).

Build the executable with the following command line :

```bash
dmd -m64 requote.d
```

## Command line

```
requote --single <file extension> <folder path>
requote --single <file extension> <input folder path> <output folder path>
requote --double <file extension> <folder path>
requote --double <file extension> <input folder path> <output folder path>
```

### Example

```bash
requote --single .js FOLDER/
```

Converts double-quoted string literals into single-quoted string literals.

```bash
requote --double .ts INPUT_FOLDER/ OUTPUT_FOLDER/
```

Converts single-quoted string literals into double-quoted string literals.

## Limitations

- There is no tokenization phase, so only safe cases involving single-line string literals are handled.

## Version

0.1

## Author

Eric Pelzer (ecstatic.coder@gmail.com).

## License

This project is licensed under the GNU General Public License version 3.

See the [LICENSE.md](LICENSE.md) file for details.
