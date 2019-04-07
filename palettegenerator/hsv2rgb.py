
# NOTE: hue (h) is in range [0;360] and r,g,b,s,v values are in range [0; 1]

def hsv2rgb(h,s,v):
    hh = h;
    if hh >= 360.0:
        hh = 0.0
    hh /= 60.0
    i = int(hh)
    ff = hh - i
    p = v * (1.0 - s)
    q = v * (1.0 - (s * ff))
    t = v * (1.0 - (s * (1.0 - ff)))
    r = 0
    g = 0
    b = 0
    if i == 0:
        r = v
        g = t
        b = p
    elif i == 1:
        r = q
        g = v
        b = p
    elif i == 2:
        r = p
        g = v
        b = t
    elif i == 3:
        r = p
        g = q
        b = v
    elif i == 4:
        r = t
        g = p
        b = v
    else:
        r = v
        g = p
        b = q
    return (r,g,b)


def testHsv2Rgb(h, s, v, r, g, b):
    (r1,g1,b1) = hsv2rgb(h,s,v)
    if r1 != r or g1 != g or b1 != b:
        print 'hsv2rgb failed on %f %f %f -> %f %f %f,  got %f %f %f instead' % (h, s, v, r, g, b, r1, g1, b1)
        
def testCreateHueRainbow():
    from PIL import Image
    width = 400
    height = 10
    image = Image.new("RGB", (width, height), (0,0,0))
    for x in range (width):
        for y in range (height):
            (r,g,b) = hsv2rgb(x / float(width) * 360, 1, 1)
            image.putpixel( (x,y), (int(r*255),int(g*255),int(b*255)) )
    image.save("rainbow.bmp", "bmp")
    
def testCreateContrastPalette():
    from PIL import Image 
    # 256 colors, each pixel represents one color
    width = 256
    height = 1
    image = Image.new("RGB", (width, height), (0,0,0))
    hsvArray = []
    rgbArray = []
    for hue in [0,30,60,90,120,150,180,210,240,270,300]:
        for saturation in [50,100]:
            for value in [40,60,80,100]:
                hsvArray.append( (hue,saturation/100.0,value/100.0) )
    for x in range (min(len(hsvArray), width)):
        (r,g,b) = hsv2rgb(hsvArray[x][0], hsvArray[x][1], hsvArray[x][2]) 
        rgbArray.append( (r,g,b) )
        image.putpixel( (x,0), (int(r*255),int(g*255),int(b*255)) )
        
    file = open('HighContrastPalette.c', 'w')
    file.write ( 'static const unsigned int highConstrastPalette[] = \n' )
    file.write ('{\n')
    i = 1
    for color in rgbArray:
        # 0x00rrggbb
        rgbValue = (int(color[0]*255) << 16) + (int(color[1]*255) << 8) + int(color[2]*255)
        file.write ( "0x%.6x, " % rgbValue)
        if (i % 10) == 0:
            file.write ( '\n')
        i = i + 1
    file.write ('\n};\n')
    
    image.save("HighContrastPalette.bmp", "bmp")

def main():
    testHsv2Rgb(0, 0, 0, 0, 0, 0)
    for hue in range(360):
        for saturation in range(100):
            testHsv2Rgb(hue, saturation  / 100.0, 0, 0, 0, 0)
            
    for hue in range(360):
        testHsv2Rgb(hue, 0, 1, 1, 1, 1)
    #testHsv2Rgb(0,   1, 1, 1, 0, 0)
    #testHsv2Rgb(200, 1, 1, 0, 169/255.0, 1)
    testCreateHueRainbow()
    testCreateContrastPalette()

# Standard boilerplate to call the main() function to begin the program.
if __name__ == '__main__':
    main()
