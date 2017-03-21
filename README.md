# DNAtracer
A suite of tools for tracing AFM images of DNA molecules.

## Notes:
This project relies on MATuiextras found at: github.com/dkovari/MATuiextras.

To update the repository to use the latest version, run:
```
git submodule update --init --recursive
```

# Usage
The main entry point for the program is DNA_Tracer.m. To use it, simple run
```
>> DNA_Tracer();
```
at the MATLAB command prompt, in the DNAtracer directory.

After initiation, the program will prompt you to select a file to load. You can either select a previously processed dataset saved as a *.mat file, or process a Nanoscope image (*.001 or *.003).