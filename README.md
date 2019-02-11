# Charmap (MIPS)

A charmap for text output implemented in a MIPS architecture.

<p align="center">
  <img src="https://i.imgur.com/49oS5CU.jpg">
</p>

### Details

```font_ROM.sv``` contains the bitmap for every character (127 in total) using the following structure:

<p align="center">
  <img src="https://i.imgur.com/zKltJs4.png">
</p>

---

```char_circuit.sv``` contains the circuit for loading each pixel coordinate from a character selection:

<p align="center">
  <img src="https://i.imgur.com/RzSoQXG.png">
</p>

---

```vga640x480.sv``` contains the main circuit where we output the RGB signals using VGA protocol.
