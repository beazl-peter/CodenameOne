/*
 * Copyright (c) 2012, Codename One and/or its affiliates. All rights reserved.
 * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
 * This code is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 2 only, as
 * published by the Free Software Foundation.  Codename One designates this
 * particular file as subject to the "Classpath" exception as provided
 * by Oracle in the LICENSE file that accompanied this code.
 *
 * This code is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
 * version 2 for more details (a copy is included in the LICENSE file that
 * accompanied this code).
 *
 * You should have received a copy of the GNU General Public License version
 * 2 along with this work; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA.
 *
 * Please contact Codename One through http://www.codenameone.com/ if you
 * need additional information or have any questions.
 */
//
//  FillPolygon.m
//  HelloWorldCN1
//
//  Created by Steve Hannah on 2014-06-03.
//
//

#import "FillPolygon.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES1/gl.h>
#import "CN1ES2compat.h"
#import "xmlvm.h"


#ifdef USE_ES2
extern GLKMatrix4 CN1modelViewMatrix;
extern GLKMatrix4 CN1projectionMatrix;
extern GLKMatrix4 CN1transformMatrix;
extern int CN1modelViewMatrixVersion;
extern int CN1projectionMatrixVersion;
extern int CN1transformMatrixVersion;
extern GLuint CN1activeProgram;
static GLuint program=0;
static GLuint vertexShader;
static GLuint fragmentShader;
static GLuint modelViewMatrixUniform;
static GLuint projectionMatrixUniform;
static GLuint transformMatrixUniform;
static GLuint colorUniform;
static GLuint vertexCoordAtt;
static GLuint textureCoordAtt;
static int currentCN1modelViewMatrixVersion=-1;
static int currentCN1projectionMatrixVersion=-1;
static int currentCN1transformMatrixVersion=-1;


static NSString *fragmentShaderSrc =
@"precision highp float;\n"
"uniform lowp vec4 uColor;\n"

"void main(){\n"
"   gl_FragColor = uColor; \n"
"}\n";

static NSString *vertexShaderSrc =
@"attribute vec4 aVertexCoord;\n"

"uniform mat4 uModelViewMatrix;\n"
"uniform mat4 uProjectionMatrix;\n"
"uniform mat4 uTransformMatrix;\n"

"void main(){\n"
"   gl_Position = uProjectionMatrix *  uModelViewMatrix * uTransformMatrix * aVertexCoord;\n"
"}";

static GLuint getOGLProgram(){
    if ( program == 0  ){
        program = CN1compileShaderProgram(vertexShaderSrc, fragmentShaderSrc);
        GLErrorLog;
        vertexCoordAtt = glGetAttribLocation(program, "aVertexCoord");
        GLErrorLog;
        
        modelViewMatrixUniform = glGetUniformLocation(program, "uModelViewMatrix");
        GLErrorLog;
        projectionMatrixUniform = glGetUniformLocation(program, "uProjectionMatrix");
        GLErrorLog;
        transformMatrixUniform = glGetUniformLocation(program, "uTransformMatrix");
        GLErrorLog;
        
        colorUniform = glGetUniformLocation(program, "uColor");
        GLErrorLog;
        
        
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        GLErrorLog;
        
        
    }
    return program;
}

#endif


@implementation FillPolygon
-(id)initWithArgs:(JAVA_FLOAT*)xCoords y:(JAVA_FLOAT*)yCoords num:(int)num color:(int)theColor alpha:(int)theAlpha
{
    color = theColor;
    alpha = theAlpha;
    size_t size = sizeof(JAVA_FLOAT)*num;
    
    x = malloc(size);
    memcpy(x, xCoords, size);
    y = malloc(size);
    memcpy(y, yCoords, size);
    numPoints = num;
    //CN1Log(@"Num points: %d", numPoints);
    return self;
}
-(void)execute
{
    glUseProgram(getOGLProgram());
    
    float alph = ((float)alpha)/255.0;
    
    GLKVector4 colorV = GLKVector4Make(((float)((color >> 16) & 0xff))/255.0 * alph,
                                       ((float)((color >> 8) & 0xff))/255.0 * alph, ((float)(color & 0xff))/255.0 * alph, alph);
    GLfloat xOffset = 0;
    GLfloat yOffset = 0;
    
#if (TARGET_OS_SIMULATOR)
    xOffset = 0;
    yOffset = 0;
#endif
    
    GLfloat vertexes[numPoints*2];// = malloc(sizeof(GLfloat)*numPoints*2);
    GLErrorLog;
    int j = 0;
    for ( int i=0; i<numPoints; i++){
        //CN1Log(@"Point: %f %f", x[i], y[i]);
        vertexes[j++] = (GLfloat)x[i];
        vertexes[j++] = (GLfloat)y[i];
    }
    
    glEnableVertexAttribArray(vertexCoordAtt);
    GLErrorLog;
    
    if (currentCN1projectionMatrixVersion != CN1projectionMatrixVersion) {
        glUniformMatrix4fv(projectionMatrixUniform, 1, 0, CN1projectionMatrix.m);
        GLErrorLog;
        currentCN1projectionMatrixVersion = CN1projectionMatrixVersion;
    }
    if (currentCN1modelViewMatrixVersion != CN1modelViewMatrixVersion) {
        glUniformMatrix4fv(modelViewMatrixUniform, 1, 0, CN1modelViewMatrix.m);
        GLErrorLog;
        currentCN1modelViewMatrixVersion = CN1modelViewMatrixVersion;
    }
    if (currentCN1transformMatrixVersion != CN1transformMatrixVersion) {
        glUniformMatrix4fv(transformMatrixUniform, 1, 0, CN1transformMatrix.m);
        GLErrorLog;
        currentCN1transformMatrixVersion = CN1transformMatrixVersion;
    }
    glUniform4fv(colorUniform, 1, colorV.v);
    GLErrorLog;
    
    //_glVertexPointer(2, GL_FLOAT, 0, vertexes);
    //GLErrorLog;
    glVertexAttribPointer(vertexCoordAtt, 2, GL_FLOAT, GL_FALSE, 0, vertexes);
    GLErrorLog;
    
    
    //GLErrorLog;
    //_glVertexPointer(2, GL_FLOAT, 0, vertexes);
    //_glEnableClientState(GL_VERTEX_ARRAY);
    //GLErrorLog;
    glDrawArrays(GL_TRIANGLE_FAN, 0, numPoints);
    //GLErrorLog;
    //_glDisableClientState(GL_VERTEX_ARRAY);
    //GLErrorLog;
    
    glDisableVertexAttribArray(vertexCoordAtt);
    GLErrorLog;
    
    //glUseProgram(CN1activeProgram);
    //GLErrorLog;
    
    
    // ---------- end
    

}

-(void)dealloc
{
    free(x);
    free(y);
}
@end
