"======================================================================
|
|   SHA1 class declarations
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2007 Free Software Foundation, Inc.
| Written by Paolo Bonzini
|
| This file is part of the GNU Smalltalk class library.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU Lesser General Public License
| as published by the Free Software Foundation; either version 2.1, or (at
| your option) any later version.
|
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
|
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.
|
 ======================================================================"

MessageDigest subclass: #SHA1
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Examples-Modules'!

!SHA1 class methodsFor: 'C call-outs'!

new
    ^self basicNew initialize
! !

!SHA1 methodsFor: 'C call-outs'!

newState
    <cCall: 'SHA1AllocOOP' returning: #smalltalk args: #()>
!

combine: input size: len into: context
    <cCall: 'SHA1Update' returning: #void args: #(#byteArray #int #byteArrayOut)>
!

finalize: state in: digest
    <cCall: 'SHA1Final' returning: #void args: #(#byteArray #byteArrayOut)>
! !

!SHA1 methodsFor: 'initialization'!

initialize
    self state: self newState
! !

!SHA1 methodsFor: 'checksumming'!

nextPut: char
    self combine: (String with: char) size: 1 into: self state
!

nextPutAll: aStringOrStream
    | buffer n |
    (aStringOrStream isKindOf: String)
	ifTrue: [
	    self
		combine: aStringOrStream
		size: aStringOrStream size
		into: self state
	]
	ifFalse: [
	    buffer := aStringOrStream species new: 1024.
	    n := 0.
	    aStringOrStream do: [ :each |
		n := n + 1.
		buffer at: n put: each.
		n = 1024 ifTrue: [
		    self combine: buffer size: n into: self state.
		    n := 0
		]
	    ].
	    self combine: buffer size: n into: self state.
	]
!

digest
    | answer |
    answer := ByteArray new: 20.
    self finalize: self state in: answer.
    ^answer
! !