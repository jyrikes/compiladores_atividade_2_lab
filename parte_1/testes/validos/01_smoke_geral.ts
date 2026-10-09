#!/usr/bin/env node
// Comentario TypeScript
const nome: string = "Ana\nMaria";
let n = 1_000 + 2.5e-3;
let hex = 0xFF, bin = 0b1010, oct = 0o755;
let enorme = 12345678901234567890n;
interface Pessoa { idade: number; }
const msg = `Ola, ${nome}! Numero: ${n+2}`;
class Conta { #saldo = 10; }
let check = n >= 1 && hex !== 0;
