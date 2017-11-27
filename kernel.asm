
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4 0f                	in     $0xf,%al

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc d0 c8 10 80       	mov    $0x8010c8d0,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 9a 37 10 80       	mov    $0x8010379a,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	c7 44 24 04 9c 87 10 	movl   $0x8010879c,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 e0 c8 10 80 	movl   $0x8010c8e0,(%esp)
80100049:	e8 5c 4d 00 00       	call   80104daa <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 2c 10 11 80 dc 	movl   $0x80110fdc,0x8011102c
80100055:	0f 11 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 30 10 11 80 dc 	movl   $0x80110fdc,0x80111030
8010005f:	0f 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 14 c9 10 80 	movl   $0x8010c914,-0xc(%ebp)
80100069:	eb 46                	jmp    801000b1 <binit+0x7d>
    b->next = bcache.head.next;
8010006b:	8b 15 30 10 11 80    	mov    0x80111030,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 50 dc 0f 11 80 	movl   $0x80110fdc,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	83 c0 0c             	add    $0xc,%eax
80100087:	c7 44 24 04 a3 87 10 	movl   $0x801087a3,0x4(%esp)
8010008e:	80 
8010008f:	89 04 24             	mov    %eax,(%esp)
80100092:	e8 d5 4b 00 00       	call   80104c6c <initsleeplock>
    bcache.head.next->prev = b;
80100097:	a1 30 10 11 80       	mov    0x80111030,%eax
8010009c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010009f:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000a5:	a3 30 10 11 80       	mov    %eax,0x80111030

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000aa:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000b1:	81 7d f4 dc 0f 11 80 	cmpl   $0x80110fdc,-0xc(%ebp)
801000b8:	72 b1                	jb     8010006b <binit+0x37>
    b->prev = &bcache.head;
    initsleeplock(&b->lock, "buffer");
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000ba:	c9                   	leave  
801000bb:	c3                   	ret    

801000bc <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000bc:	55                   	push   %ebp
801000bd:	89 e5                	mov    %esp,%ebp
801000bf:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000c2:	c7 04 24 e0 c8 10 80 	movl   $0x8010c8e0,(%esp)
801000c9:	e8 fd 4c 00 00       	call   80104dcb <acquire>

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000ce:	a1 30 10 11 80       	mov    0x80111030,%eax
801000d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000d6:	eb 50                	jmp    80100128 <bget+0x6c>
    if(b->dev == dev && b->blockno == blockno){
801000d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000db:	8b 40 04             	mov    0x4(%eax),%eax
801000de:	3b 45 08             	cmp    0x8(%ebp),%eax
801000e1:	75 3c                	jne    8010011f <bget+0x63>
801000e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e6:	8b 40 08             	mov    0x8(%eax),%eax
801000e9:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000ec:	75 31                	jne    8010011f <bget+0x63>
      b->refcnt++;
801000ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f1:	8b 40 4c             	mov    0x4c(%eax),%eax
801000f4:	8d 50 01             	lea    0x1(%eax),%edx
801000f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000fa:	89 50 4c             	mov    %edx,0x4c(%eax)
      release(&bcache.lock);
801000fd:	c7 04 24 e0 c8 10 80 	movl   $0x8010c8e0,(%esp)
80100104:	e8 2c 4d 00 00       	call   80104e35 <release>
      acquiresleep(&b->lock);
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	83 c0 0c             	add    $0xc,%eax
8010010f:	89 04 24             	mov    %eax,(%esp)
80100112:	e8 8f 4b 00 00       	call   80104ca6 <acquiresleep>
      return b;
80100117:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011a:	e9 94 00 00 00       	jmp    801001b3 <bget+0xf7>
  struct buf *b;

  acquire(&bcache.lock);

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
8010011f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100122:	8b 40 54             	mov    0x54(%eax),%eax
80100125:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100128:	81 7d f4 dc 0f 11 80 	cmpl   $0x80110fdc,-0xc(%ebp)
8010012f:	75 a7                	jne    801000d8 <bget+0x1c>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100131:	a1 2c 10 11 80       	mov    0x8011102c,%eax
80100136:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100139:	eb 63                	jmp    8010019e <bget+0xe2>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
8010013b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010013e:	8b 40 4c             	mov    0x4c(%eax),%eax
80100141:	85 c0                	test   %eax,%eax
80100143:	75 50                	jne    80100195 <bget+0xd9>
80100145:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100148:	8b 00                	mov    (%eax),%eax
8010014a:	83 e0 04             	and    $0x4,%eax
8010014d:	85 c0                	test   %eax,%eax
8010014f:	75 44                	jne    80100195 <bget+0xd9>
      b->dev = dev;
80100151:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100154:	8b 55 08             	mov    0x8(%ebp),%edx
80100157:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	8b 55 0c             	mov    0xc(%ebp),%edx
80100160:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = 0;
80100163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100166:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      b->refcnt = 1;
8010016c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016f:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
      release(&bcache.lock);
80100176:	c7 04 24 e0 c8 10 80 	movl   $0x8010c8e0,(%esp)
8010017d:	e8 b3 4c 00 00       	call   80104e35 <release>
      acquiresleep(&b->lock);
80100182:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100185:	83 c0 0c             	add    $0xc,%eax
80100188:	89 04 24             	mov    %eax,(%esp)
8010018b:	e8 16 4b 00 00       	call   80104ca6 <acquiresleep>
      return b;
80100190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100193:	eb 1e                	jmp    801001b3 <bget+0xf7>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100195:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100198:	8b 40 50             	mov    0x50(%eax),%eax
8010019b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010019e:	81 7d f4 dc 0f 11 80 	cmpl   $0x80110fdc,-0xc(%ebp)
801001a5:	75 94                	jne    8010013b <bget+0x7f>
      release(&bcache.lock);
      acquiresleep(&b->lock);
      return b;
    }
  }
  panic("bget: no buffers");
801001a7:	c7 04 24 aa 87 10 80 	movl   $0x801087aa,(%esp)
801001ae:	e8 a1 03 00 00       	call   80100554 <panic>
}
801001b3:	c9                   	leave  
801001b4:	c3                   	ret    

801001b5 <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001b5:	55                   	push   %ebp
801001b6:	89 e5                	mov    %esp,%ebp
801001b8:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001bb:	8b 45 0c             	mov    0xc(%ebp),%eax
801001be:	89 44 24 04          	mov    %eax,0x4(%esp)
801001c2:	8b 45 08             	mov    0x8(%ebp),%eax
801001c5:	89 04 24             	mov    %eax,(%esp)
801001c8:	e8 ef fe ff ff       	call   801000bc <bget>
801001cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((b->flags & B_VALID) == 0) {
801001d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d3:	8b 00                	mov    (%eax),%eax
801001d5:	83 e0 02             	and    $0x2,%eax
801001d8:	85 c0                	test   %eax,%eax
801001da:	75 0b                	jne    801001e7 <bread+0x32>
    iderw(b);
801001dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001df:	89 04 24             	mov    %eax,(%esp)
801001e2:	e8 ea 26 00 00       	call   801028d1 <iderw>
  }
  return b;
801001e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001ea:	c9                   	leave  
801001eb:	c3                   	ret    

801001ec <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
801001ec:	55                   	push   %ebp
801001ed:	89 e5                	mov    %esp,%ebp
801001ef:	83 ec 18             	sub    $0x18,%esp
  if(!holdingsleep(&b->lock))
801001f2:	8b 45 08             	mov    0x8(%ebp),%eax
801001f5:	83 c0 0c             	add    $0xc,%eax
801001f8:	89 04 24             	mov    %eax,(%esp)
801001fb:	e8 43 4b 00 00       	call   80104d43 <holdingsleep>
80100200:	85 c0                	test   %eax,%eax
80100202:	75 0c                	jne    80100210 <bwrite+0x24>
    panic("bwrite");
80100204:	c7 04 24 bb 87 10 80 	movl   $0x801087bb,(%esp)
8010020b:	e8 44 03 00 00       	call   80100554 <panic>
  b->flags |= B_DIRTY;
80100210:	8b 45 08             	mov    0x8(%ebp),%eax
80100213:	8b 00                	mov    (%eax),%eax
80100215:	83 c8 04             	or     $0x4,%eax
80100218:	89 c2                	mov    %eax,%edx
8010021a:	8b 45 08             	mov    0x8(%ebp),%eax
8010021d:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010021f:	8b 45 08             	mov    0x8(%ebp),%eax
80100222:	89 04 24             	mov    %eax,(%esp)
80100225:	e8 a7 26 00 00       	call   801028d1 <iderw>
}
8010022a:	c9                   	leave  
8010022b:	c3                   	ret    

8010022c <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
8010022c:	55                   	push   %ebp
8010022d:	89 e5                	mov    %esp,%ebp
8010022f:	83 ec 18             	sub    $0x18,%esp
  if(!holdingsleep(&b->lock))
80100232:	8b 45 08             	mov    0x8(%ebp),%eax
80100235:	83 c0 0c             	add    $0xc,%eax
80100238:	89 04 24             	mov    %eax,(%esp)
8010023b:	e8 03 4b 00 00       	call   80104d43 <holdingsleep>
80100240:	85 c0                	test   %eax,%eax
80100242:	75 0c                	jne    80100250 <brelse+0x24>
    panic("brelse");
80100244:	c7 04 24 c2 87 10 80 	movl   $0x801087c2,(%esp)
8010024b:	e8 04 03 00 00       	call   80100554 <panic>

  releasesleep(&b->lock);
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	83 c0 0c             	add    $0xc,%eax
80100256:	89 04 24             	mov    %eax,(%esp)
80100259:	e8 a3 4a 00 00       	call   80104d01 <releasesleep>

  acquire(&bcache.lock);
8010025e:	c7 04 24 e0 c8 10 80 	movl   $0x8010c8e0,(%esp)
80100265:	e8 61 4b 00 00       	call   80104dcb <acquire>
  b->refcnt--;
8010026a:	8b 45 08             	mov    0x8(%ebp),%eax
8010026d:	8b 40 4c             	mov    0x4c(%eax),%eax
80100270:	8d 50 ff             	lea    -0x1(%eax),%edx
80100273:	8b 45 08             	mov    0x8(%ebp),%eax
80100276:	89 50 4c             	mov    %edx,0x4c(%eax)
  if (b->refcnt == 0) {
80100279:	8b 45 08             	mov    0x8(%ebp),%eax
8010027c:	8b 40 4c             	mov    0x4c(%eax),%eax
8010027f:	85 c0                	test   %eax,%eax
80100281:	75 47                	jne    801002ca <brelse+0x9e>
    // no one is waiting for it.
    b->next->prev = b->prev;
80100283:	8b 45 08             	mov    0x8(%ebp),%eax
80100286:	8b 40 54             	mov    0x54(%eax),%eax
80100289:	8b 55 08             	mov    0x8(%ebp),%edx
8010028c:	8b 52 50             	mov    0x50(%edx),%edx
8010028f:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
80100292:	8b 45 08             	mov    0x8(%ebp),%eax
80100295:	8b 40 50             	mov    0x50(%eax),%eax
80100298:	8b 55 08             	mov    0x8(%ebp),%edx
8010029b:	8b 52 54             	mov    0x54(%edx),%edx
8010029e:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
801002a1:	8b 15 30 10 11 80    	mov    0x80111030,%edx
801002a7:	8b 45 08             	mov    0x8(%ebp),%eax
801002aa:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801002ad:	8b 45 08             	mov    0x8(%ebp),%eax
801002b0:	c7 40 50 dc 0f 11 80 	movl   $0x80110fdc,0x50(%eax)
    bcache.head.next->prev = b;
801002b7:	a1 30 10 11 80       	mov    0x80111030,%eax
801002bc:	8b 55 08             	mov    0x8(%ebp),%edx
801002bf:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801002c2:	8b 45 08             	mov    0x8(%ebp),%eax
801002c5:	a3 30 10 11 80       	mov    %eax,0x80111030
  }
  
  release(&bcache.lock);
801002ca:	c7 04 24 e0 c8 10 80 	movl   $0x8010c8e0,(%esp)
801002d1:	e8 5f 4b 00 00       	call   80104e35 <release>
}
801002d6:	c9                   	leave  
801002d7:	c3                   	ret    

801002d8 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002d8:	55                   	push   %ebp
801002d9:	89 e5                	mov    %esp,%ebp
801002db:	83 ec 14             	sub    $0x14,%esp
801002de:	8b 45 08             	mov    0x8(%ebp),%eax
801002e1:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801002e8:	89 c2                	mov    %eax,%edx
801002ea:	ec                   	in     (%dx),%al
801002eb:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002ee:	8a 45 ff             	mov    -0x1(%ebp),%al
}
801002f1:	c9                   	leave  
801002f2:	c3                   	ret    

801002f3 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002f3:	55                   	push   %ebp
801002f4:	89 e5                	mov    %esp,%ebp
801002f6:	83 ec 08             	sub    $0x8,%esp
801002f9:	8b 45 08             	mov    0x8(%ebp),%eax
801002fc:	8b 55 0c             	mov    0xc(%ebp),%edx
801002ff:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80100303:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100306:	8a 45 f8             	mov    -0x8(%ebp),%al
80100309:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010030c:	ee                   	out    %al,(%dx)
}
8010030d:	c9                   	leave  
8010030e:	c3                   	ret    

8010030f <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
8010030f:	55                   	push   %ebp
80100310:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100312:	fa                   	cli    
}
80100313:	5d                   	pop    %ebp
80100314:	c3                   	ret    

80100315 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100315:	55                   	push   %ebp
80100316:	89 e5                	mov    %esp,%ebp
80100318:	56                   	push   %esi
80100319:	53                   	push   %ebx
8010031a:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010031d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100321:	74 1c                	je     8010033f <printint+0x2a>
80100323:	8b 45 08             	mov    0x8(%ebp),%eax
80100326:	c1 e8 1f             	shr    $0x1f,%eax
80100329:	0f b6 c0             	movzbl %al,%eax
8010032c:	89 45 10             	mov    %eax,0x10(%ebp)
8010032f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100333:	74 0a                	je     8010033f <printint+0x2a>
    x = -xx;
80100335:	8b 45 08             	mov    0x8(%ebp),%eax
80100338:	f7 d8                	neg    %eax
8010033a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010033d:	eb 06                	jmp    80100345 <printint+0x30>
  else
    x = xx;
8010033f:	8b 45 08             	mov    0x8(%ebp),%eax
80100342:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100345:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010034c:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010034f:	8d 41 01             	lea    0x1(%ecx),%eax
80100352:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100355:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100358:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010035b:	ba 00 00 00 00       	mov    $0x0,%edx
80100360:	f7 f3                	div    %ebx
80100362:	89 d0                	mov    %edx,%eax
80100364:	8a 80 08 90 10 80    	mov    -0x7fef6ff8(%eax),%al
8010036a:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
8010036e:	8b 75 0c             	mov    0xc(%ebp),%esi
80100371:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100374:	ba 00 00 00 00       	mov    $0x0,%edx
80100379:	f7 f6                	div    %esi
8010037b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010037e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100382:	75 c8                	jne    8010034c <printint+0x37>

  if(sign)
80100384:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100388:	74 10                	je     8010039a <printint+0x85>
    buf[i++] = '-';
8010038a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038d:	8d 50 01             	lea    0x1(%eax),%edx
80100390:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100393:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
80100398:	eb 17                	jmp    801003b1 <printint+0x9c>
8010039a:	eb 15                	jmp    801003b1 <printint+0x9c>
    consputc(buf[i]);
8010039c:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010039f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003a2:	01 d0                	add    %edx,%eax
801003a4:	8a 00                	mov    (%eax),%al
801003a6:	0f be c0             	movsbl %al,%eax
801003a9:	89 04 24             	mov    %eax,(%esp)
801003ac:	e8 b7 03 00 00       	call   80100768 <consputc>
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
801003b1:	ff 4d f4             	decl   -0xc(%ebp)
801003b4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003b8:	79 e2                	jns    8010039c <printint+0x87>
    consputc(buf[i]);
}
801003ba:	83 c4 30             	add    $0x30,%esp
801003bd:	5b                   	pop    %ebx
801003be:	5e                   	pop    %esi
801003bf:	5d                   	pop    %ebp
801003c0:	c3                   	ret    

801003c1 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003c1:	55                   	push   %ebp
801003c2:	89 e5                	mov    %esp,%ebp
801003c4:	83 ec 38             	sub    $0x38,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003c7:	a1 74 b8 10 80       	mov    0x8010b874,%eax
801003cc:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003cf:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003d3:	74 0c                	je     801003e1 <cprintf+0x20>
    acquire(&cons.lock);
801003d5:	c7 04 24 40 b8 10 80 	movl   $0x8010b840,(%esp)
801003dc:	e8 ea 49 00 00       	call   80104dcb <acquire>

  if (fmt == 0)
801003e1:	8b 45 08             	mov    0x8(%ebp),%eax
801003e4:	85 c0                	test   %eax,%eax
801003e6:	75 0c                	jne    801003f4 <cprintf+0x33>
    panic("null fmt");
801003e8:	c7 04 24 c9 87 10 80 	movl   $0x801087c9,(%esp)
801003ef:	e8 60 01 00 00       	call   80100554 <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003f4:	8d 45 0c             	lea    0xc(%ebp),%eax
801003f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801003fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100401:	e9 1b 01 00 00       	jmp    80100521 <cprintf+0x160>
    if(c != '%'){
80100406:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
8010040a:	74 10                	je     8010041c <cprintf+0x5b>
      consputc(c);
8010040c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010040f:	89 04 24             	mov    %eax,(%esp)
80100412:	e8 51 03 00 00       	call   80100768 <consputc>
      continue;
80100417:	e9 02 01 00 00       	jmp    8010051e <cprintf+0x15d>
    }
    c = fmt[++i] & 0xff;
8010041c:	8b 55 08             	mov    0x8(%ebp),%edx
8010041f:	ff 45 f4             	incl   -0xc(%ebp)
80100422:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100425:	01 d0                	add    %edx,%eax
80100427:	8a 00                	mov    (%eax),%al
80100429:	0f be c0             	movsbl %al,%eax
8010042c:	25 ff 00 00 00       	and    $0xff,%eax
80100431:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100434:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100438:	75 05                	jne    8010043f <cprintf+0x7e>
      break;
8010043a:	e9 01 01 00 00       	jmp    80100540 <cprintf+0x17f>
    switch(c){
8010043f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100442:	83 f8 70             	cmp    $0x70,%eax
80100445:	74 4f                	je     80100496 <cprintf+0xd5>
80100447:	83 f8 70             	cmp    $0x70,%eax
8010044a:	7f 13                	jg     8010045f <cprintf+0x9e>
8010044c:	83 f8 25             	cmp    $0x25,%eax
8010044f:	0f 84 a3 00 00 00    	je     801004f8 <cprintf+0x137>
80100455:	83 f8 64             	cmp    $0x64,%eax
80100458:	74 14                	je     8010046e <cprintf+0xad>
8010045a:	e9 a7 00 00 00       	jmp    80100506 <cprintf+0x145>
8010045f:	83 f8 73             	cmp    $0x73,%eax
80100462:	74 57                	je     801004bb <cprintf+0xfa>
80100464:	83 f8 78             	cmp    $0x78,%eax
80100467:	74 2d                	je     80100496 <cprintf+0xd5>
80100469:	e9 98 00 00 00       	jmp    80100506 <cprintf+0x145>
    case 'd':
      printint(*argp++, 10, 1);
8010046e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100471:	8d 50 04             	lea    0x4(%eax),%edx
80100474:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100477:	8b 00                	mov    (%eax),%eax
80100479:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80100480:	00 
80100481:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80100488:	00 
80100489:	89 04 24             	mov    %eax,(%esp)
8010048c:	e8 84 fe ff ff       	call   80100315 <printint>
      break;
80100491:	e9 88 00 00 00       	jmp    8010051e <cprintf+0x15d>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
80100496:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100499:	8d 50 04             	lea    0x4(%eax),%edx
8010049c:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010049f:	8b 00                	mov    (%eax),%eax
801004a1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801004a8:	00 
801004a9:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
801004b0:	00 
801004b1:	89 04 24             	mov    %eax,(%esp)
801004b4:	e8 5c fe ff ff       	call   80100315 <printint>
      break;
801004b9:	eb 63                	jmp    8010051e <cprintf+0x15d>
    case 's':
      if((s = (char*)*argp++) == 0)
801004bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004be:	8d 50 04             	lea    0x4(%eax),%edx
801004c1:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c4:	8b 00                	mov    (%eax),%eax
801004c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004c9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004cd:	75 09                	jne    801004d8 <cprintf+0x117>
        s = "(null)";
801004cf:	c7 45 ec d2 87 10 80 	movl   $0x801087d2,-0x14(%ebp)
      for(; *s; s++)
801004d6:	eb 15                	jmp    801004ed <cprintf+0x12c>
801004d8:	eb 13                	jmp    801004ed <cprintf+0x12c>
        consputc(*s);
801004da:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004dd:	8a 00                	mov    (%eax),%al
801004df:	0f be c0             	movsbl %al,%eax
801004e2:	89 04 24             	mov    %eax,(%esp)
801004e5:	e8 7e 02 00 00       	call   80100768 <consputc>
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004ea:	ff 45 ec             	incl   -0x14(%ebp)
801004ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004f0:	8a 00                	mov    (%eax),%al
801004f2:	84 c0                	test   %al,%al
801004f4:	75 e4                	jne    801004da <cprintf+0x119>
        consputc(*s);
      break;
801004f6:	eb 26                	jmp    8010051e <cprintf+0x15d>
    case '%':
      consputc('%');
801004f8:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004ff:	e8 64 02 00 00       	call   80100768 <consputc>
      break;
80100504:	eb 18                	jmp    8010051e <cprintf+0x15d>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
80100506:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
8010050d:	e8 56 02 00 00       	call   80100768 <consputc>
      consputc(c);
80100512:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100515:	89 04 24             	mov    %eax,(%esp)
80100518:	e8 4b 02 00 00       	call   80100768 <consputc>
      break;
8010051d:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010051e:	ff 45 f4             	incl   -0xc(%ebp)
80100521:	8b 55 08             	mov    0x8(%ebp),%edx
80100524:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100527:	01 d0                	add    %edx,%eax
80100529:	8a 00                	mov    (%eax),%al
8010052b:	0f be c0             	movsbl %al,%eax
8010052e:	25 ff 00 00 00       	and    $0xff,%eax
80100533:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100536:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010053a:	0f 85 c6 fe ff ff    	jne    80100406 <cprintf+0x45>
      consputc(c);
      break;
    }
  }

  if(locking)
80100540:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100544:	74 0c                	je     80100552 <cprintf+0x191>
    release(&cons.lock);
80100546:	c7 04 24 40 b8 10 80 	movl   $0x8010b840,(%esp)
8010054d:	e8 e3 48 00 00       	call   80104e35 <release>
}
80100552:	c9                   	leave  
80100553:	c3                   	ret    

80100554 <panic>:

void
panic(char *s)
{
80100554:	55                   	push   %ebp
80100555:	89 e5                	mov    %esp,%ebp
80100557:	83 ec 48             	sub    $0x48,%esp
  int i;
  uint pcs[10];

  cli();
8010055a:	e8 b0 fd ff ff       	call   8010030f <cli>
  cons.locking = 0;
8010055f:	c7 05 74 b8 10 80 00 	movl   $0x0,0x8010b874
80100566:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
80100569:	e8 ff 29 00 00       	call   80102f6d <lapicid>
8010056e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100572:	c7 04 24 d9 87 10 80 	movl   $0x801087d9,(%esp)
80100579:	e8 43 fe ff ff       	call   801003c1 <cprintf>
  cprintf(s);
8010057e:	8b 45 08             	mov    0x8(%ebp),%eax
80100581:	89 04 24             	mov    %eax,(%esp)
80100584:	e8 38 fe ff ff       	call   801003c1 <cprintf>
  cprintf("\n");
80100589:	c7 04 24 ed 87 10 80 	movl   $0x801087ed,(%esp)
80100590:	e8 2c fe ff ff       	call   801003c1 <cprintf>
  getcallerpcs(&s, pcs);
80100595:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100598:	89 44 24 04          	mov    %eax,0x4(%esp)
8010059c:	8d 45 08             	lea    0x8(%ebp),%eax
8010059f:	89 04 24             	mov    %eax,(%esp)
801005a2:	e8 db 48 00 00       	call   80104e82 <getcallerpcs>
  for(i=0; i<10; i++)
801005a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005ae:	eb 1a                	jmp    801005ca <panic+0x76>
    cprintf(" %p", pcs[i]);
801005b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005b3:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005b7:	89 44 24 04          	mov    %eax,0x4(%esp)
801005bb:	c7 04 24 ef 87 10 80 	movl   $0x801087ef,(%esp)
801005c2:	e8 fa fd ff ff       	call   801003c1 <cprintf>
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005c7:	ff 45 f4             	incl   -0xc(%ebp)
801005ca:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005ce:	7e e0                	jle    801005b0 <panic+0x5c>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005d0:	c7 05 2c b8 10 80 01 	movl   $0x1,0x8010b82c
801005d7:	00 00 00 
  for(;;)
    ;
801005da:	eb fe                	jmp    801005da <panic+0x86>

801005dc <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
801005dc:	55                   	push   %ebp
801005dd:	89 e5                	mov    %esp,%ebp
801005df:	83 ec 28             	sub    $0x28,%esp
  int pos;

  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801005e2:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801005e9:	00 
801005ea:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801005f1:	e8 fd fc ff ff       	call   801002f3 <outb>
  pos = inb(CRTPORT+1) << 8;
801005f6:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
801005fd:	e8 d6 fc ff ff       	call   801002d8 <inb>
80100602:	0f b6 c0             	movzbl %al,%eax
80100605:	c1 e0 08             	shl    $0x8,%eax
80100608:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
8010060b:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100612:	00 
80100613:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
8010061a:	e8 d4 fc ff ff       	call   801002f3 <outb>
  pos |= inb(CRTPORT+1);
8010061f:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100626:	e8 ad fc ff ff       	call   801002d8 <inb>
8010062b:	0f b6 c0             	movzbl %al,%eax
8010062e:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
80100631:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100635:	75 1b                	jne    80100652 <cgaputc+0x76>
    pos += 80 - pos%80;
80100637:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010063a:	b9 50 00 00 00       	mov    $0x50,%ecx
8010063f:	99                   	cltd   
80100640:	f7 f9                	idiv   %ecx
80100642:	89 d0                	mov    %edx,%eax
80100644:	ba 50 00 00 00       	mov    $0x50,%edx
80100649:	29 c2                	sub    %eax,%edx
8010064b:	89 d0                	mov    %edx,%eax
8010064d:	01 45 f4             	add    %eax,-0xc(%ebp)
80100650:	eb 34                	jmp    80100686 <cgaputc+0xaa>
  else if(c == BACKSPACE){
80100652:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100659:	75 0b                	jne    80100666 <cgaputc+0x8a>
    if(pos > 0) --pos;
8010065b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010065f:	7e 25                	jle    80100686 <cgaputc+0xaa>
80100661:	ff 4d f4             	decl   -0xc(%ebp)
80100664:	eb 20                	jmp    80100686 <cgaputc+0xaa>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100666:	8b 0d 04 90 10 80    	mov    0x80109004,%ecx
8010066c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010066f:	8d 50 01             	lea    0x1(%eax),%edx
80100672:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100675:	01 c0                	add    %eax,%eax
80100677:	8d 14 01             	lea    (%ecx,%eax,1),%edx
8010067a:	8b 45 08             	mov    0x8(%ebp),%eax
8010067d:	0f b6 c0             	movzbl %al,%eax
80100680:	80 cc 07             	or     $0x7,%ah
80100683:	66 89 02             	mov    %ax,(%edx)

  if(pos < 0 || pos > 25*80)
80100686:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010068a:	78 09                	js     80100695 <cgaputc+0xb9>
8010068c:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
80100693:	7e 0c                	jle    801006a1 <cgaputc+0xc5>
    panic("pos under/overflow");
80100695:	c7 04 24 f3 87 10 80 	movl   $0x801087f3,(%esp)
8010069c:	e8 b3 fe ff ff       	call   80100554 <panic>

  if((pos/80) >= 24){  // Scroll up.
801006a1:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006a8:	7e 53                	jle    801006fd <cgaputc+0x121>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006aa:	a1 04 90 10 80       	mov    0x80109004,%eax
801006af:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006b5:	a1 04 90 10 80       	mov    0x80109004,%eax
801006ba:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
801006c1:	00 
801006c2:	89 54 24 04          	mov    %edx,0x4(%esp)
801006c6:	89 04 24             	mov    %eax,(%esp)
801006c9:	e8 29 4a 00 00       	call   801050f7 <memmove>
    pos -= 80;
801006ce:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006d2:	b8 80 07 00 00       	mov    $0x780,%eax
801006d7:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006da:	01 c0                	add    %eax,%eax
801006dc:	8b 0d 04 90 10 80    	mov    0x80109004,%ecx
801006e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801006e5:	01 d2                	add    %edx,%edx
801006e7:	01 ca                	add    %ecx,%edx
801006e9:	89 44 24 08          	mov    %eax,0x8(%esp)
801006ed:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801006f4:	00 
801006f5:	89 14 24             	mov    %edx,(%esp)
801006f8:	e8 31 49 00 00       	call   8010502e <memset>
  }

  outb(CRTPORT, 14);
801006fd:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
80100704:	00 
80100705:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
8010070c:	e8 e2 fb ff ff       	call   801002f3 <outb>
  outb(CRTPORT+1, pos>>8);
80100711:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100714:	c1 f8 08             	sar    $0x8,%eax
80100717:	0f b6 c0             	movzbl %al,%eax
8010071a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010071e:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100725:	e8 c9 fb ff ff       	call   801002f3 <outb>
  outb(CRTPORT, 15);
8010072a:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100731:	00 
80100732:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100739:	e8 b5 fb ff ff       	call   801002f3 <outb>
  outb(CRTPORT+1, pos);
8010073e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100741:	0f b6 c0             	movzbl %al,%eax
80100744:	89 44 24 04          	mov    %eax,0x4(%esp)
80100748:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
8010074f:	e8 9f fb ff ff       	call   801002f3 <outb>
  crt[pos] = ' ' | 0x0700;
80100754:	8b 15 04 90 10 80    	mov    0x80109004,%edx
8010075a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010075d:	01 c0                	add    %eax,%eax
8010075f:	01 d0                	add    %edx,%eax
80100761:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
80100766:	c9                   	leave  
80100767:	c3                   	ret    

80100768 <consputc>:

void
consputc(int c)
{
80100768:	55                   	push   %ebp
80100769:	89 e5                	mov    %esp,%ebp
8010076b:	83 ec 18             	sub    $0x18,%esp
  if(panicked){
8010076e:	a1 2c b8 10 80       	mov    0x8010b82c,%eax
80100773:	85 c0                	test   %eax,%eax
80100775:	74 07                	je     8010077e <consputc+0x16>
    cli();
80100777:	e8 93 fb ff ff       	call   8010030f <cli>
    for(;;)
      ;
8010077c:	eb fe                	jmp    8010077c <consputc+0x14>
  }

  if(c == BACKSPACE){
8010077e:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100785:	75 26                	jne    801007ad <consputc+0x45>
    uartputc('\b'); uartputc(' '); uartputc('\b');
80100787:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010078e:	e8 81 64 00 00       	call   80106c14 <uartputc>
80100793:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010079a:	e8 75 64 00 00       	call   80106c14 <uartputc>
8010079f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801007a6:	e8 69 64 00 00       	call   80106c14 <uartputc>
801007ab:	eb 0b                	jmp    801007b8 <consputc+0x50>
  } else
    uartputc(c);
801007ad:	8b 45 08             	mov    0x8(%ebp),%eax
801007b0:	89 04 24             	mov    %eax,(%esp)
801007b3:	e8 5c 64 00 00       	call   80106c14 <uartputc>
  cgaputc(c);
801007b8:	8b 45 08             	mov    0x8(%ebp),%eax
801007bb:	89 04 24             	mov    %eax,(%esp)
801007be:	e8 19 fe ff ff       	call   801005dc <cgaputc>
}
801007c3:	c9                   	leave  
801007c4:	c3                   	ret    

801007c5 <copy_buf>:

#define C(x)  ((x)-'@')  // Control-x


void copy_buf(char *dst, char *src, int len)
{
801007c5:	55                   	push   %ebp
801007c6:	89 e5                	mov    %esp,%ebp
801007c8:	83 ec 10             	sub    $0x10,%esp
  int i;

  for (i = 0; i < len; i++) {
801007cb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801007d2:	eb 17                	jmp    801007eb <copy_buf+0x26>
    dst[i] = src[i];
801007d4:	8b 55 fc             	mov    -0x4(%ebp),%edx
801007d7:	8b 45 08             	mov    0x8(%ebp),%eax
801007da:	01 c2                	add    %eax,%edx
801007dc:	8b 4d fc             	mov    -0x4(%ebp),%ecx
801007df:	8b 45 0c             	mov    0xc(%ebp),%eax
801007e2:	01 c8                	add    %ecx,%eax
801007e4:	8a 00                	mov    (%eax),%al
801007e6:	88 02                	mov    %al,(%edx)

void copy_buf(char *dst, char *src, int len)
{
  int i;

  for (i = 0; i < len; i++) {
801007e8:	ff 45 fc             	incl   -0x4(%ebp)
801007eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801007ee:	3b 45 10             	cmp    0x10(%ebp),%eax
801007f1:	7c e1                	jl     801007d4 <copy_buf+0xf>
    dst[i] = src[i];
  }
}
801007f3:	c9                   	leave  
801007f4:	c3                   	ret    

801007f5 <consoleintr>:

void
consoleintr(int (*getc)(void))
{
801007f5:	55                   	push   %ebp
801007f6:	89 e5                	mov    %esp,%ebp
801007f8:	83 ec 28             	sub    $0x28,%esp
  int c, doprocdump = 0, doconsoleswitch = 0;
801007fb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100802:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

  acquire(&cons.lock);
80100809:	c7 04 24 40 b8 10 80 	movl   $0x8010b840,(%esp)
80100810:	e8 b6 45 00 00       	call   80104dcb <acquire>
  while((c = getc()) >= 0){
80100815:	e9 6d 01 00 00       	jmp    80100987 <consoleintr+0x192>
    switch(c){
8010081a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010081d:	83 f8 14             	cmp    $0x14,%eax
80100820:	74 37                	je     80100859 <consoleintr+0x64>
80100822:	83 f8 14             	cmp    $0x14,%eax
80100825:	7f 13                	jg     8010083a <consoleintr+0x45>
80100827:	83 f8 08             	cmp    $0x8,%eax
8010082a:	0f 84 98 00 00 00    	je     801008c8 <consoleintr+0xd3>
80100830:	83 f8 10             	cmp    $0x10,%eax
80100833:	74 18                	je     8010084d <consoleintr+0x58>
80100835:	e9 be 00 00 00       	jmp    801008f8 <consoleintr+0x103>
8010083a:	83 f8 15             	cmp    $0x15,%eax
8010083d:	74 61                	je     801008a0 <consoleintr+0xab>
8010083f:	83 f8 7f             	cmp    $0x7f,%eax
80100842:	0f 84 80 00 00 00    	je     801008c8 <consoleintr+0xd3>
80100848:	e9 ab 00 00 00       	jmp    801008f8 <consoleintr+0x103>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
8010084d:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100854:	e9 2e 01 00 00       	jmp    80100987 <consoleintr+0x192>
    case C('T'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      if (active+1 > MAX_VC){
80100859:	a1 00 90 10 80       	mov    0x80109000,%eax
8010085e:	40                   	inc    %eax
8010085f:	83 f8 04             	cmp    $0x4,%eax
80100862:	7e 0c                	jle    80100870 <consoleintr+0x7b>
        active = 1;
80100864:	c7 05 00 90 10 80 01 	movl   $0x1,0x80109000
8010086b:	00 00 00 
8010086e:	eb 0b                	jmp    8010087b <consoleintr+0x86>
      } else{
        active = active + 1;
80100870:	a1 00 90 10 80       	mov    0x80109000,%eax
80100875:	40                   	inc    %eax
80100876:	a3 00 90 10 80       	mov    %eax,0x80109000
      }
      doconsoleswitch = 1;
8010087b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      break;
80100882:	e9 00 01 00 00       	jmp    80100987 <consoleintr+0x192>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100887:	a1 c8 12 11 80       	mov    0x801112c8,%eax
8010088c:	48                   	dec    %eax
8010088d:	a3 c8 12 11 80       	mov    %eax,0x801112c8
        consputc(BACKSPACE);
80100892:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
80100899:	e8 ca fe ff ff       	call   80100768 <consputc>
8010089e:	eb 01                	jmp    801008a1 <consoleintr+0xac>
        active = active + 1;
      }
      doconsoleswitch = 1;
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
801008a0:	90                   	nop
801008a1:	8b 15 c8 12 11 80    	mov    0x801112c8,%edx
801008a7:	a1 c4 12 11 80       	mov    0x801112c4,%eax
801008ac:	39 c2                	cmp    %eax,%edx
801008ae:	74 13                	je     801008c3 <consoleintr+0xce>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
801008b0:	a1 c8 12 11 80       	mov    0x801112c8,%eax
801008b5:	48                   	dec    %eax
801008b6:	83 e0 7f             	and    $0x7f,%eax
801008b9:	8a 80 40 12 11 80    	mov    -0x7feeedc0(%eax),%al
        active = active + 1;
      }
      doconsoleswitch = 1;
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
801008bf:	3c 0a                	cmp    $0xa,%al
801008c1:	75 c4                	jne    80100887 <consoleintr+0x92>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
801008c3:	e9 bf 00 00 00       	jmp    80100987 <consoleintr+0x192>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
801008c8:	8b 15 c8 12 11 80    	mov    0x801112c8,%edx
801008ce:	a1 c4 12 11 80       	mov    0x801112c4,%eax
801008d3:	39 c2                	cmp    %eax,%edx
801008d5:	74 1c                	je     801008f3 <consoleintr+0xfe>
        input.e--;
801008d7:	a1 c8 12 11 80       	mov    0x801112c8,%eax
801008dc:	48                   	dec    %eax
801008dd:	a3 c8 12 11 80       	mov    %eax,0x801112c8
        consputc(BACKSPACE);
801008e2:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
801008e9:	e8 7a fe ff ff       	call   80100768 <consputc>
      }
      break;
801008ee:	e9 94 00 00 00       	jmp    80100987 <consoleintr+0x192>
801008f3:	e9 8f 00 00 00       	jmp    80100987 <consoleintr+0x192>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008f8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801008fc:	0f 84 84 00 00 00    	je     80100986 <consoleintr+0x191>
80100902:	8b 15 c8 12 11 80    	mov    0x801112c8,%edx
80100908:	a1 c0 12 11 80       	mov    0x801112c0,%eax
8010090d:	29 c2                	sub    %eax,%edx
8010090f:	89 d0                	mov    %edx,%eax
80100911:	83 f8 7f             	cmp    $0x7f,%eax
80100914:	77 70                	ja     80100986 <consoleintr+0x191>
        c = (c == '\r') ? '\n' : c;
80100916:	83 7d ec 0d          	cmpl   $0xd,-0x14(%ebp)
8010091a:	74 05                	je     80100921 <consoleintr+0x12c>
8010091c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010091f:	eb 05                	jmp    80100926 <consoleintr+0x131>
80100921:	b8 0a 00 00 00       	mov    $0xa,%eax
80100926:	89 45 ec             	mov    %eax,-0x14(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
80100929:	a1 c8 12 11 80       	mov    0x801112c8,%eax
8010092e:	8d 50 01             	lea    0x1(%eax),%edx
80100931:	89 15 c8 12 11 80    	mov    %edx,0x801112c8
80100937:	83 e0 7f             	and    $0x7f,%eax
8010093a:	89 c2                	mov    %eax,%edx
8010093c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010093f:	88 82 40 12 11 80    	mov    %al,-0x7feeedc0(%edx)
        consputc(c);
80100945:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100948:	89 04 24             	mov    %eax,(%esp)
8010094b:	e8 18 fe ff ff       	call   80100768 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100950:	83 7d ec 0a          	cmpl   $0xa,-0x14(%ebp)
80100954:	74 18                	je     8010096e <consoleintr+0x179>
80100956:	83 7d ec 04          	cmpl   $0x4,-0x14(%ebp)
8010095a:	74 12                	je     8010096e <consoleintr+0x179>
8010095c:	a1 c8 12 11 80       	mov    0x801112c8,%eax
80100961:	8b 15 c0 12 11 80    	mov    0x801112c0,%edx
80100967:	83 ea 80             	sub    $0xffffff80,%edx
8010096a:	39 d0                	cmp    %edx,%eax
8010096c:	75 18                	jne    80100986 <consoleintr+0x191>
          input.w = input.e;
8010096e:	a1 c8 12 11 80       	mov    0x801112c8,%eax
80100973:	a3 c4 12 11 80       	mov    %eax,0x801112c4
          wakeup(&input.r);
80100978:	c7 04 24 c0 12 11 80 	movl   $0x801112c0,(%esp)
8010097f:	e8 4d 41 00 00       	call   80104ad1 <wakeup>
        }
      }
      break;
80100984:	eb 00                	jmp    80100986 <consoleintr+0x191>
80100986:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c, doprocdump = 0, doconsoleswitch = 0;

  acquire(&cons.lock);
  while((c = getc()) >= 0){
80100987:	8b 45 08             	mov    0x8(%ebp),%eax
8010098a:	ff d0                	call   *%eax
8010098c:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010098f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80100993:	0f 89 81 fe ff ff    	jns    8010081a <consoleintr+0x25>
        }
      }
      break;
    }
  }
  release(&cons.lock);
80100999:	c7 04 24 40 b8 10 80 	movl   $0x8010b840,(%esp)
801009a0:	e8 90 44 00 00       	call   80104e35 <release>
  if(doprocdump){
801009a5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801009a9:	74 05                	je     801009b0 <consoleintr+0x1bb>
    procdump();  // now call procdump() wo. cons.lock held
801009ab:	e8 c4 41 00 00       	call   80104b74 <procdump>
  }
  if(doconsoleswitch){
801009b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801009b4:	74 15                	je     801009cb <consoleintr+0x1d6>
    cprintf("\nActive console now: %d\n", active);
801009b6:	a1 00 90 10 80       	mov    0x80109000,%eax
801009bb:	89 44 24 04          	mov    %eax,0x4(%esp)
801009bf:	c7 04 24 06 88 10 80 	movl   $0x80108806,(%esp)
801009c6:	e8 f6 f9 ff ff       	call   801003c1 <cprintf>
  }
}
801009cb:	c9                   	leave  
801009cc:	c3                   	ret    

801009cd <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
801009cd:	55                   	push   %ebp
801009ce:	89 e5                	mov    %esp,%ebp
801009d0:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c;

  iunlock(ip);
801009d3:	8b 45 08             	mov    0x8(%ebp),%eax
801009d6:	89 04 24             	mov    %eax,(%esp)
801009d9:	e8 ea 10 00 00       	call   80101ac8 <iunlock>
  target = n;
801009de:	8b 45 10             	mov    0x10(%ebp),%eax
801009e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
801009e4:	c7 04 24 40 b8 10 80 	movl   $0x8010b840,(%esp)
801009eb:	e8 db 43 00 00       	call   80104dcb <acquire>
  while(n > 0){
801009f0:	e9 b7 00 00 00       	jmp    80100aac <consoleread+0xdf>
    while((input.r == input.w) || (active != ip->minor)){
801009f5:	eb 41                	jmp    80100a38 <consoleread+0x6b>
      if(myproc()->killed){
801009f7:	e8 b3 37 00 00       	call   801041af <myproc>
801009fc:	8b 40 24             	mov    0x24(%eax),%eax
801009ff:	85 c0                	test   %eax,%eax
80100a01:	74 21                	je     80100a24 <consoleread+0x57>
        release(&cons.lock);
80100a03:	c7 04 24 40 b8 10 80 	movl   $0x8010b840,(%esp)
80100a0a:	e8 26 44 00 00       	call   80104e35 <release>
        ilock(ip);
80100a0f:	8b 45 08             	mov    0x8(%ebp),%eax
80100a12:	89 04 24             	mov    %eax,(%esp)
80100a15:	e8 a4 0f 00 00       	call   801019be <ilock>
        return -1;
80100a1a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100a1f:	e9 b3 00 00 00       	jmp    80100ad7 <consoleread+0x10a>
      }
      sleep(&input.r, &cons.lock);
80100a24:	c7 44 24 04 40 b8 10 	movl   $0x8010b840,0x4(%esp)
80100a2b:	80 
80100a2c:	c7 04 24 c0 12 11 80 	movl   $0x801112c0,(%esp)
80100a33:	e8 c5 3f 00 00       	call   801049fd <sleep>

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while((input.r == input.w) || (active != ip->minor)){
80100a38:	8b 15 c0 12 11 80    	mov    0x801112c0,%edx
80100a3e:	a1 c4 12 11 80       	mov    0x801112c4,%eax
80100a43:	39 c2                	cmp    %eax,%edx
80100a45:	74 b0                	je     801009f7 <consoleread+0x2a>
80100a47:	8b 45 08             	mov    0x8(%ebp),%eax
80100a4a:	8b 40 54             	mov    0x54(%eax),%eax
80100a4d:	0f bf d0             	movswl %ax,%edx
80100a50:	a1 00 90 10 80       	mov    0x80109000,%eax
80100a55:	39 c2                	cmp    %eax,%edx
80100a57:	75 9e                	jne    801009f7 <consoleread+0x2a>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a59:	a1 c0 12 11 80       	mov    0x801112c0,%eax
80100a5e:	8d 50 01             	lea    0x1(%eax),%edx
80100a61:	89 15 c0 12 11 80    	mov    %edx,0x801112c0
80100a67:	83 e0 7f             	and    $0x7f,%eax
80100a6a:	8a 80 40 12 11 80    	mov    -0x7feeedc0(%eax),%al
80100a70:	0f be c0             	movsbl %al,%eax
80100a73:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a76:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a7a:	75 17                	jne    80100a93 <consoleread+0xc6>
      if(n < target){
80100a7c:	8b 45 10             	mov    0x10(%ebp),%eax
80100a7f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100a82:	73 0d                	jae    80100a91 <consoleread+0xc4>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a84:	a1 c0 12 11 80       	mov    0x801112c0,%eax
80100a89:	48                   	dec    %eax
80100a8a:	a3 c0 12 11 80       	mov    %eax,0x801112c0
      }
      break;
80100a8f:	eb 25                	jmp    80100ab6 <consoleread+0xe9>
80100a91:	eb 23                	jmp    80100ab6 <consoleread+0xe9>
    }
    *dst++ = c;
80100a93:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a96:	8d 50 01             	lea    0x1(%eax),%edx
80100a99:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a9c:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a9f:	88 10                	mov    %dl,(%eax)
    --n;
80100aa1:	ff 4d 10             	decl   0x10(%ebp)
    if(c == '\n')
80100aa4:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100aa8:	75 02                	jne    80100aac <consoleread+0xdf>
      break;
80100aaa:	eb 0a                	jmp    80100ab6 <consoleread+0xe9>
  int c;

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
80100aac:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100ab0:	0f 8f 3f ff ff ff    	jg     801009f5 <consoleread+0x28>
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
  }
  release(&cons.lock);
80100ab6:	c7 04 24 40 b8 10 80 	movl   $0x8010b840,(%esp)
80100abd:	e8 73 43 00 00       	call   80104e35 <release>
  ilock(ip);
80100ac2:	8b 45 08             	mov    0x8(%ebp),%eax
80100ac5:	89 04 24             	mov    %eax,(%esp)
80100ac8:	e8 f1 0e 00 00       	call   801019be <ilock>

  return target - n;
80100acd:	8b 45 10             	mov    0x10(%ebp),%eax
80100ad0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100ad3:	29 c2                	sub    %eax,%edx
80100ad5:	89 d0                	mov    %edx,%eax
}
80100ad7:	c9                   	leave  
80100ad8:	c3                   	ret    

80100ad9 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100ad9:	55                   	push   %ebp
80100ada:	89 e5                	mov    %esp,%ebp
80100adc:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (active == ip->minor){
80100adf:	8b 45 08             	mov    0x8(%ebp),%eax
80100ae2:	8b 40 54             	mov    0x54(%eax),%eax
80100ae5:	0f bf d0             	movswl %ax,%edx
80100ae8:	a1 00 90 10 80       	mov    0x80109000,%eax
80100aed:	39 c2                	cmp    %eax,%edx
80100aef:	75 5a                	jne    80100b4b <consolewrite+0x72>
    iunlock(ip);
80100af1:	8b 45 08             	mov    0x8(%ebp),%eax
80100af4:	89 04 24             	mov    %eax,(%esp)
80100af7:	e8 cc 0f 00 00       	call   80101ac8 <iunlock>
    acquire(&cons.lock);
80100afc:	c7 04 24 40 b8 10 80 	movl   $0x8010b840,(%esp)
80100b03:	e8 c3 42 00 00       	call   80104dcb <acquire>
    for(i = 0; i < n; i++)
80100b08:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100b0f:	eb 1b                	jmp    80100b2c <consolewrite+0x53>
      consputc(buf[i] & 0xff);
80100b11:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b14:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b17:	01 d0                	add    %edx,%eax
80100b19:	8a 00                	mov    (%eax),%al
80100b1b:	0f be c0             	movsbl %al,%eax
80100b1e:	0f b6 c0             	movzbl %al,%eax
80100b21:	89 04 24             	mov    %eax,(%esp)
80100b24:	e8 3f fc ff ff       	call   80100768 <consputc>
  int i;

  if (active == ip->minor){
    iunlock(ip);
    acquire(&cons.lock);
    for(i = 0; i < n; i++)
80100b29:	ff 45 f4             	incl   -0xc(%ebp)
80100b2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b2f:	3b 45 10             	cmp    0x10(%ebp),%eax
80100b32:	7c dd                	jl     80100b11 <consolewrite+0x38>
      consputc(buf[i] & 0xff);
    release(&cons.lock);
80100b34:	c7 04 24 40 b8 10 80 	movl   $0x8010b840,(%esp)
80100b3b:	e8 f5 42 00 00       	call   80104e35 <release>
    ilock(ip);
80100b40:	8b 45 08             	mov    0x8(%ebp),%eax
80100b43:	89 04 24             	mov    %eax,(%esp)
80100b46:	e8 73 0e 00 00       	call   801019be <ilock>
  }
  return n;
80100b4b:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100b4e:	c9                   	leave  
80100b4f:	c3                   	ret    

80100b50 <consoleinit>:

void
consoleinit(void)
{
80100b50:	55                   	push   %ebp
80100b51:	89 e5                	mov    %esp,%ebp
80100b53:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100b56:	c7 44 24 04 1f 88 10 	movl   $0x8010881f,0x4(%esp)
80100b5d:	80 
80100b5e:	c7 04 24 40 b8 10 80 	movl   $0x8010b840,(%esp)
80100b65:	e8 40 42 00 00       	call   80104daa <initlock>

  devsw[CONSOLE].write = consolewrite;
80100b6a:	c7 05 8c 1c 11 80 d9 	movl   $0x80100ad9,0x80111c8c
80100b71:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b74:	c7 05 88 1c 11 80 cd 	movl   $0x801009cd,0x80111c88
80100b7b:	09 10 80 
  cons.locking = 1;
80100b7e:	c7 05 74 b8 10 80 01 	movl   $0x1,0x8010b874
80100b85:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100b88:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100b8f:	00 
80100b90:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100b97:	e8 e7 1e 00 00       	call   80102a83 <ioapicenable>
}
80100b9c:	c9                   	leave  
80100b9d:	c3                   	ret    
	...

80100ba0 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100ba0:	55                   	push   %ebp
80100ba1:	89 e5                	mov    %esp,%ebp
80100ba3:	81 ec 38 01 00 00    	sub    $0x138,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100ba9:	e8 01 36 00 00       	call   801041af <myproc>
80100bae:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100bb1:	e8 01 29 00 00       	call   801034b7 <begin_op>

  if((ip = namei(path)) == 0){
80100bb6:	8b 45 08             	mov    0x8(%ebp),%eax
80100bb9:	89 04 24             	mov    %eax,(%esp)
80100bbc:	e8 22 19 00 00       	call   801024e3 <namei>
80100bc1:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100bc4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bc8:	75 1b                	jne    80100be5 <exec+0x45>
    end_op();
80100bca:	e8 6a 29 00 00       	call   80103539 <end_op>
    cprintf("exec: fail\n");
80100bcf:	c7 04 24 27 88 10 80 	movl   $0x80108827,(%esp)
80100bd6:	e8 e6 f7 ff ff       	call   801003c1 <cprintf>
    return -1;
80100bdb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100be0:	e9 f6 03 00 00       	jmp    80100fdb <exec+0x43b>
  }
  ilock(ip);
80100be5:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100be8:	89 04 24             	mov    %eax,(%esp)
80100beb:	e8 ce 0d 00 00       	call   801019be <ilock>
  pgdir = 0;
80100bf0:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100bf7:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100bfe:	00 
80100bff:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100c06:	00 
80100c07:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100c0d:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c11:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100c14:	89 04 24             	mov    %eax,(%esp)
80100c17:	e8 39 12 00 00       	call   80101e55 <readi>
80100c1c:	83 f8 34             	cmp    $0x34,%eax
80100c1f:	74 05                	je     80100c26 <exec+0x86>
    goto bad;
80100c21:	e9 89 03 00 00       	jmp    80100faf <exec+0x40f>
  if(elf.magic != ELF_MAGIC)
80100c26:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100c2c:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c31:	74 05                	je     80100c38 <exec+0x98>
    goto bad;
80100c33:	e9 77 03 00 00       	jmp    80100faf <exec+0x40f>

  if((pgdir = setupkvm()) == 0)
80100c38:	e8 b9 6f 00 00       	call   80107bf6 <setupkvm>
80100c3d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c40:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c44:	75 05                	jne    80100c4b <exec+0xab>
    goto bad;
80100c46:	e9 64 03 00 00       	jmp    80100faf <exec+0x40f>

  // Load program into memory.
  sz = 0;
80100c4b:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c52:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c59:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100c5f:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c62:	e9 fb 00 00 00       	jmp    80100d62 <exec+0x1c2>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c67:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c6a:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100c71:	00 
80100c72:	89 44 24 08          	mov    %eax,0x8(%esp)
80100c76:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100c7c:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c80:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100c83:	89 04 24             	mov    %eax,(%esp)
80100c86:	e8 ca 11 00 00       	call   80101e55 <readi>
80100c8b:	83 f8 20             	cmp    $0x20,%eax
80100c8e:	74 05                	je     80100c95 <exec+0xf5>
      goto bad;
80100c90:	e9 1a 03 00 00       	jmp    80100faf <exec+0x40f>
    if(ph.type != ELF_PROG_LOAD)
80100c95:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100c9b:	83 f8 01             	cmp    $0x1,%eax
80100c9e:	74 05                	je     80100ca5 <exec+0x105>
      continue;
80100ca0:	e9 b1 00 00 00       	jmp    80100d56 <exec+0x1b6>
    if(ph.memsz < ph.filesz)
80100ca5:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100cab:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100cb1:	39 c2                	cmp    %eax,%edx
80100cb3:	73 05                	jae    80100cba <exec+0x11a>
      goto bad;
80100cb5:	e9 f5 02 00 00       	jmp    80100faf <exec+0x40f>
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100cba:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100cc0:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cc6:	01 c2                	add    %eax,%edx
80100cc8:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cce:	39 c2                	cmp    %eax,%edx
80100cd0:	73 05                	jae    80100cd7 <exec+0x137>
      goto bad;
80100cd2:	e9 d8 02 00 00       	jmp    80100faf <exec+0x40f>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100cd7:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100cdd:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100ce3:	01 d0                	add    %edx,%eax
80100ce5:	89 44 24 08          	mov    %eax,0x8(%esp)
80100ce9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cec:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cf0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100cf3:	89 04 24             	mov    %eax,(%esp)
80100cf6:	e8 c7 72 00 00       	call   80107fc2 <allocuvm>
80100cfb:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cfe:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d02:	75 05                	jne    80100d09 <exec+0x169>
      goto bad;
80100d04:	e9 a6 02 00 00       	jmp    80100faf <exec+0x40f>
    if(ph.vaddr % PGSIZE != 0)
80100d09:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100d0f:	25 ff 0f 00 00       	and    $0xfff,%eax
80100d14:	85 c0                	test   %eax,%eax
80100d16:	74 05                	je     80100d1d <exec+0x17d>
      goto bad;
80100d18:	e9 92 02 00 00       	jmp    80100faf <exec+0x40f>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100d1d:	8b 8d f8 fe ff ff    	mov    -0x108(%ebp),%ecx
80100d23:	8b 95 ec fe ff ff    	mov    -0x114(%ebp),%edx
80100d29:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100d2f:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100d33:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100d37:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100d3a:	89 54 24 08          	mov    %edx,0x8(%esp)
80100d3e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d42:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100d45:	89 04 24             	mov    %eax,(%esp)
80100d48:	e8 92 71 00 00       	call   80107edf <loaduvm>
80100d4d:	85 c0                	test   %eax,%eax
80100d4f:	79 05                	jns    80100d56 <exec+0x1b6>
      goto bad;
80100d51:	e9 59 02 00 00       	jmp    80100faf <exec+0x40f>
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d56:	ff 45 ec             	incl   -0x14(%ebp)
80100d59:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d5c:	83 c0 20             	add    $0x20,%eax
80100d5f:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d62:	8b 85 34 ff ff ff    	mov    -0xcc(%ebp),%eax
80100d68:	0f b7 c0             	movzwl %ax,%eax
80100d6b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100d6e:	0f 8f f3 fe ff ff    	jg     80100c67 <exec+0xc7>
    if(ph.vaddr % PGSIZE != 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100d74:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100d77:	89 04 24             	mov    %eax,(%esp)
80100d7a:	e8 3e 0e 00 00       	call   80101bbd <iunlockput>
  end_op();
80100d7f:	e8 b5 27 00 00       	call   80103539 <end_op>
  ip = 0;
80100d84:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100d8b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d8e:	05 ff 0f 00 00       	add    $0xfff,%eax
80100d93:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100d98:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d9b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d9e:	05 00 20 00 00       	add    $0x2000,%eax
80100da3:	89 44 24 08          	mov    %eax,0x8(%esp)
80100da7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100daa:	89 44 24 04          	mov    %eax,0x4(%esp)
80100dae:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100db1:	89 04 24             	mov    %eax,(%esp)
80100db4:	e8 09 72 00 00       	call   80107fc2 <allocuvm>
80100db9:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100dbc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100dc0:	75 05                	jne    80100dc7 <exec+0x227>
    goto bad;
80100dc2:	e9 e8 01 00 00       	jmp    80100faf <exec+0x40f>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100dc7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100dca:	2d 00 20 00 00       	sub    $0x2000,%eax
80100dcf:	89 44 24 04          	mov    %eax,0x4(%esp)
80100dd3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100dd6:	89 04 24             	mov    %eax,(%esp)
80100dd9:	e8 54 74 00 00       	call   80108232 <clearpteu>
  sp = sz;
80100dde:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100de1:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100de4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100deb:	e9 95 00 00 00       	jmp    80100e85 <exec+0x2e5>
    if(argc >= MAXARG)
80100df0:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100df4:	76 05                	jbe    80100dfb <exec+0x25b>
      goto bad;
80100df6:	e9 b4 01 00 00       	jmp    80100faf <exec+0x40f>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100dfb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dfe:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e05:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e08:	01 d0                	add    %edx,%eax
80100e0a:	8b 00                	mov    (%eax),%eax
80100e0c:	89 04 24             	mov    %eax,(%esp)
80100e0f:	e8 6d 44 00 00       	call   80105281 <strlen>
80100e14:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100e17:	29 c2                	sub    %eax,%edx
80100e19:	89 d0                	mov    %edx,%eax
80100e1b:	48                   	dec    %eax
80100e1c:	83 e0 fc             	and    $0xfffffffc,%eax
80100e1f:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100e22:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e25:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e2c:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e2f:	01 d0                	add    %edx,%eax
80100e31:	8b 00                	mov    (%eax),%eax
80100e33:	89 04 24             	mov    %eax,(%esp)
80100e36:	e8 46 44 00 00       	call   80105281 <strlen>
80100e3b:	40                   	inc    %eax
80100e3c:	89 c2                	mov    %eax,%edx
80100e3e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e41:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100e48:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e4b:	01 c8                	add    %ecx,%eax
80100e4d:	8b 00                	mov    (%eax),%eax
80100e4f:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100e53:	89 44 24 08          	mov    %eax,0x8(%esp)
80100e57:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e5a:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e5e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100e61:	89 04 24             	mov    %eax,(%esp)
80100e64:	e8 81 75 00 00       	call   801083ea <copyout>
80100e69:	85 c0                	test   %eax,%eax
80100e6b:	79 05                	jns    80100e72 <exec+0x2d2>
      goto bad;
80100e6d:	e9 3d 01 00 00       	jmp    80100faf <exec+0x40f>
    ustack[3+argc] = sp;
80100e72:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e75:	8d 50 03             	lea    0x3(%eax),%edx
80100e78:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e7b:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100e82:	ff 45 e4             	incl   -0x1c(%ebp)
80100e85:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e88:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e8f:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e92:	01 d0                	add    %edx,%eax
80100e94:	8b 00                	mov    (%eax),%eax
80100e96:	85 c0                	test   %eax,%eax
80100e98:	0f 85 52 ff ff ff    	jne    80100df0 <exec+0x250>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100e9e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ea1:	83 c0 03             	add    $0x3,%eax
80100ea4:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100eab:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100eaf:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100eb6:	ff ff ff 
  ustack[1] = argc;
80100eb9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ebc:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100ec2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ec5:	40                   	inc    %eax
80100ec6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ecd:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ed0:	29 d0                	sub    %edx,%eax
80100ed2:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100ed8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100edb:	83 c0 04             	add    $0x4,%eax
80100ede:	c1 e0 02             	shl    $0x2,%eax
80100ee1:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100ee4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ee7:	83 c0 04             	add    $0x4,%eax
80100eea:	c1 e0 02             	shl    $0x2,%eax
80100eed:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100ef1:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100ef7:	89 44 24 08          	mov    %eax,0x8(%esp)
80100efb:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100efe:	89 44 24 04          	mov    %eax,0x4(%esp)
80100f02:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100f05:	89 04 24             	mov    %eax,(%esp)
80100f08:	e8 dd 74 00 00       	call   801083ea <copyout>
80100f0d:	85 c0                	test   %eax,%eax
80100f0f:	79 05                	jns    80100f16 <exec+0x376>
    goto bad;
80100f11:	e9 99 00 00 00       	jmp    80100faf <exec+0x40f>

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100f16:	8b 45 08             	mov    0x8(%ebp),%eax
80100f19:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100f1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f1f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100f22:	eb 13                	jmp    80100f37 <exec+0x397>
    if(*s == '/')
80100f24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f27:	8a 00                	mov    (%eax),%al
80100f29:	3c 2f                	cmp    $0x2f,%al
80100f2b:	75 07                	jne    80100f34 <exec+0x394>
      last = s+1;
80100f2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f30:	40                   	inc    %eax
80100f31:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100f34:	ff 45 f4             	incl   -0xc(%ebp)
80100f37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f3a:	8a 00                	mov    (%eax),%al
80100f3c:	84 c0                	test   %al,%al
80100f3e:	75 e4                	jne    80100f24 <exec+0x384>
    if(*s == '/')
      last = s+1;
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100f40:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f43:	8d 50 6c             	lea    0x6c(%eax),%edx
80100f46:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80100f4d:	00 
80100f4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100f51:	89 44 24 04          	mov    %eax,0x4(%esp)
80100f55:	89 14 24             	mov    %edx,(%esp)
80100f58:	e8 dd 42 00 00       	call   8010523a <safestrcpy>

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100f5d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f60:	8b 40 04             	mov    0x4(%eax),%eax
80100f63:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80100f66:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f69:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f6c:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100f6f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f72:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f75:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100f77:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f7a:	8b 40 18             	mov    0x18(%eax),%eax
80100f7d:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100f83:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100f86:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f89:	8b 40 18             	mov    0x18(%eax),%eax
80100f8c:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f8f:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80100f92:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f95:	89 04 24             	mov    %eax,(%esp)
80100f98:	e8 33 6d 00 00       	call   80107cd0 <switchuvm>
  freevm(oldpgdir);
80100f9d:	8b 45 cc             	mov    -0x34(%ebp),%eax
80100fa0:	89 04 24             	mov    %eax,(%esp)
80100fa3:	e8 f4 71 00 00       	call   8010819c <freevm>
  return 0;
80100fa8:	b8 00 00 00 00       	mov    $0x0,%eax
80100fad:	eb 2c                	jmp    80100fdb <exec+0x43b>

 bad:
  if(pgdir)
80100faf:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100fb3:	74 0b                	je     80100fc0 <exec+0x420>
    freevm(pgdir);
80100fb5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100fb8:	89 04 24             	mov    %eax,(%esp)
80100fbb:	e8 dc 71 00 00       	call   8010819c <freevm>
  if(ip){
80100fc0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100fc4:	74 10                	je     80100fd6 <exec+0x436>
    iunlockput(ip);
80100fc6:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100fc9:	89 04 24             	mov    %eax,(%esp)
80100fcc:	e8 ec 0b 00 00       	call   80101bbd <iunlockput>
    end_op();
80100fd1:	e8 63 25 00 00       	call   80103539 <end_op>
  }
  return -1;
80100fd6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100fdb:	c9                   	leave  
80100fdc:	c3                   	ret    
80100fdd:	00 00                	add    %al,(%eax)
	...

80100fe0 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100fe0:	55                   	push   %ebp
80100fe1:	89 e5                	mov    %esp,%ebp
80100fe3:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
80100fe6:	c7 44 24 04 33 88 10 	movl   $0x80108833,0x4(%esp)
80100fed:	80 
80100fee:	c7 04 24 e0 12 11 80 	movl   $0x801112e0,(%esp)
80100ff5:	e8 b0 3d 00 00       	call   80104daa <initlock>
}
80100ffa:	c9                   	leave  
80100ffb:	c3                   	ret    

80100ffc <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100ffc:	55                   	push   %ebp
80100ffd:	89 e5                	mov    %esp,%ebp
80100fff:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
80101002:	c7 04 24 e0 12 11 80 	movl   $0x801112e0,(%esp)
80101009:	e8 bd 3d 00 00       	call   80104dcb <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010100e:	c7 45 f4 14 13 11 80 	movl   $0x80111314,-0xc(%ebp)
80101015:	eb 29                	jmp    80101040 <filealloc+0x44>
    if(f->ref == 0){
80101017:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010101a:	8b 40 04             	mov    0x4(%eax),%eax
8010101d:	85 c0                	test   %eax,%eax
8010101f:	75 1b                	jne    8010103c <filealloc+0x40>
      f->ref = 1;
80101021:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101024:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
8010102b:	c7 04 24 e0 12 11 80 	movl   $0x801112e0,(%esp)
80101032:	e8 fe 3d 00 00       	call   80104e35 <release>
      return f;
80101037:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010103a:	eb 1e                	jmp    8010105a <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010103c:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101040:	81 7d f4 74 1c 11 80 	cmpl   $0x80111c74,-0xc(%ebp)
80101047:	72 ce                	jb     80101017 <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80101049:	c7 04 24 e0 12 11 80 	movl   $0x801112e0,(%esp)
80101050:	e8 e0 3d 00 00       	call   80104e35 <release>
  return 0;
80101055:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010105a:	c9                   	leave  
8010105b:	c3                   	ret    

8010105c <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
8010105c:	55                   	push   %ebp
8010105d:	89 e5                	mov    %esp,%ebp
8010105f:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
80101062:	c7 04 24 e0 12 11 80 	movl   $0x801112e0,(%esp)
80101069:	e8 5d 3d 00 00       	call   80104dcb <acquire>
  if(f->ref < 1)
8010106e:	8b 45 08             	mov    0x8(%ebp),%eax
80101071:	8b 40 04             	mov    0x4(%eax),%eax
80101074:	85 c0                	test   %eax,%eax
80101076:	7f 0c                	jg     80101084 <filedup+0x28>
    panic("filedup");
80101078:	c7 04 24 3a 88 10 80 	movl   $0x8010883a,(%esp)
8010107f:	e8 d0 f4 ff ff       	call   80100554 <panic>
  f->ref++;
80101084:	8b 45 08             	mov    0x8(%ebp),%eax
80101087:	8b 40 04             	mov    0x4(%eax),%eax
8010108a:	8d 50 01             	lea    0x1(%eax),%edx
8010108d:	8b 45 08             	mov    0x8(%ebp),%eax
80101090:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101093:	c7 04 24 e0 12 11 80 	movl   $0x801112e0,(%esp)
8010109a:	e8 96 3d 00 00       	call   80104e35 <release>
  return f;
8010109f:	8b 45 08             	mov    0x8(%ebp),%eax
}
801010a2:	c9                   	leave  
801010a3:	c3                   	ret    

801010a4 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801010a4:	55                   	push   %ebp
801010a5:	89 e5                	mov    %esp,%ebp
801010a7:	57                   	push   %edi
801010a8:	56                   	push   %esi
801010a9:	53                   	push   %ebx
801010aa:	83 ec 3c             	sub    $0x3c,%esp
  struct file ff;

  acquire(&ftable.lock);
801010ad:	c7 04 24 e0 12 11 80 	movl   $0x801112e0,(%esp)
801010b4:	e8 12 3d 00 00       	call   80104dcb <acquire>
  if(f->ref < 1)
801010b9:	8b 45 08             	mov    0x8(%ebp),%eax
801010bc:	8b 40 04             	mov    0x4(%eax),%eax
801010bf:	85 c0                	test   %eax,%eax
801010c1:	7f 0c                	jg     801010cf <fileclose+0x2b>
    panic("fileclose");
801010c3:	c7 04 24 42 88 10 80 	movl   $0x80108842,(%esp)
801010ca:	e8 85 f4 ff ff       	call   80100554 <panic>
  if(--f->ref > 0){
801010cf:	8b 45 08             	mov    0x8(%ebp),%eax
801010d2:	8b 40 04             	mov    0x4(%eax),%eax
801010d5:	8d 50 ff             	lea    -0x1(%eax),%edx
801010d8:	8b 45 08             	mov    0x8(%ebp),%eax
801010db:	89 50 04             	mov    %edx,0x4(%eax)
801010de:	8b 45 08             	mov    0x8(%ebp),%eax
801010e1:	8b 40 04             	mov    0x4(%eax),%eax
801010e4:	85 c0                	test   %eax,%eax
801010e6:	7e 0e                	jle    801010f6 <fileclose+0x52>
    release(&ftable.lock);
801010e8:	c7 04 24 e0 12 11 80 	movl   $0x801112e0,(%esp)
801010ef:	e8 41 3d 00 00       	call   80104e35 <release>
801010f4:	eb 70                	jmp    80101166 <fileclose+0xc2>
    return;
  }
  ff = *f;
801010f6:	8b 45 08             	mov    0x8(%ebp),%eax
801010f9:	8d 55 d0             	lea    -0x30(%ebp),%edx
801010fc:	89 c3                	mov    %eax,%ebx
801010fe:	b8 06 00 00 00       	mov    $0x6,%eax
80101103:	89 d7                	mov    %edx,%edi
80101105:	89 de                	mov    %ebx,%esi
80101107:	89 c1                	mov    %eax,%ecx
80101109:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  f->ref = 0;
8010110b:	8b 45 08             	mov    0x8(%ebp),%eax
8010110e:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101115:	8b 45 08             	mov    0x8(%ebp),%eax
80101118:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
8010111e:	c7 04 24 e0 12 11 80 	movl   $0x801112e0,(%esp)
80101125:	e8 0b 3d 00 00       	call   80104e35 <release>

  if(ff.type == FD_PIPE)
8010112a:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010112d:	83 f8 01             	cmp    $0x1,%eax
80101130:	75 17                	jne    80101149 <fileclose+0xa5>
    pipeclose(ff.pipe, ff.writable);
80101132:	8a 45 d9             	mov    -0x27(%ebp),%al
80101135:	0f be d0             	movsbl %al,%edx
80101138:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010113b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010113f:	89 04 24             	mov    %eax,(%esp)
80101142:	e8 00 2d 00 00       	call   80103e47 <pipeclose>
80101147:	eb 1d                	jmp    80101166 <fileclose+0xc2>
  else if(ff.type == FD_INODE){
80101149:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010114c:	83 f8 02             	cmp    $0x2,%eax
8010114f:	75 15                	jne    80101166 <fileclose+0xc2>
    begin_op();
80101151:	e8 61 23 00 00       	call   801034b7 <begin_op>
    iput(ff.ip);
80101156:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101159:	89 04 24             	mov    %eax,(%esp)
8010115c:	e8 ab 09 00 00       	call   80101b0c <iput>
    end_op();
80101161:	e8 d3 23 00 00       	call   80103539 <end_op>
  }
}
80101166:	83 c4 3c             	add    $0x3c,%esp
80101169:	5b                   	pop    %ebx
8010116a:	5e                   	pop    %esi
8010116b:	5f                   	pop    %edi
8010116c:	5d                   	pop    %ebp
8010116d:	c3                   	ret    

8010116e <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
8010116e:	55                   	push   %ebp
8010116f:	89 e5                	mov    %esp,%ebp
80101171:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
80101174:	8b 45 08             	mov    0x8(%ebp),%eax
80101177:	8b 00                	mov    (%eax),%eax
80101179:	83 f8 02             	cmp    $0x2,%eax
8010117c:	75 38                	jne    801011b6 <filestat+0x48>
    ilock(f->ip);
8010117e:	8b 45 08             	mov    0x8(%ebp),%eax
80101181:	8b 40 10             	mov    0x10(%eax),%eax
80101184:	89 04 24             	mov    %eax,(%esp)
80101187:	e8 32 08 00 00       	call   801019be <ilock>
    stati(f->ip, st);
8010118c:	8b 45 08             	mov    0x8(%ebp),%eax
8010118f:	8b 40 10             	mov    0x10(%eax),%eax
80101192:	8b 55 0c             	mov    0xc(%ebp),%edx
80101195:	89 54 24 04          	mov    %edx,0x4(%esp)
80101199:	89 04 24             	mov    %eax,(%esp)
8010119c:	e8 70 0c 00 00       	call   80101e11 <stati>
    iunlock(f->ip);
801011a1:	8b 45 08             	mov    0x8(%ebp),%eax
801011a4:	8b 40 10             	mov    0x10(%eax),%eax
801011a7:	89 04 24             	mov    %eax,(%esp)
801011aa:	e8 19 09 00 00       	call   80101ac8 <iunlock>
    return 0;
801011af:	b8 00 00 00 00       	mov    $0x0,%eax
801011b4:	eb 05                	jmp    801011bb <filestat+0x4d>
  }
  return -1;
801011b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801011bb:	c9                   	leave  
801011bc:	c3                   	ret    

801011bd <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801011bd:	55                   	push   %ebp
801011be:	89 e5                	mov    %esp,%ebp
801011c0:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
801011c3:	8b 45 08             	mov    0x8(%ebp),%eax
801011c6:	8a 40 08             	mov    0x8(%eax),%al
801011c9:	84 c0                	test   %al,%al
801011cb:	75 0a                	jne    801011d7 <fileread+0x1a>
    return -1;
801011cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011d2:	e9 9f 00 00 00       	jmp    80101276 <fileread+0xb9>
  if(f->type == FD_PIPE)
801011d7:	8b 45 08             	mov    0x8(%ebp),%eax
801011da:	8b 00                	mov    (%eax),%eax
801011dc:	83 f8 01             	cmp    $0x1,%eax
801011df:	75 1e                	jne    801011ff <fileread+0x42>
    return piperead(f->pipe, addr, n);
801011e1:	8b 45 08             	mov    0x8(%ebp),%eax
801011e4:	8b 40 0c             	mov    0xc(%eax),%eax
801011e7:	8b 55 10             	mov    0x10(%ebp),%edx
801011ea:	89 54 24 08          	mov    %edx,0x8(%esp)
801011ee:	8b 55 0c             	mov    0xc(%ebp),%edx
801011f1:	89 54 24 04          	mov    %edx,0x4(%esp)
801011f5:	89 04 24             	mov    %eax,(%esp)
801011f8:	e8 c8 2d 00 00       	call   80103fc5 <piperead>
801011fd:	eb 77                	jmp    80101276 <fileread+0xb9>
  if(f->type == FD_INODE){
801011ff:	8b 45 08             	mov    0x8(%ebp),%eax
80101202:	8b 00                	mov    (%eax),%eax
80101204:	83 f8 02             	cmp    $0x2,%eax
80101207:	75 61                	jne    8010126a <fileread+0xad>
    ilock(f->ip);
80101209:	8b 45 08             	mov    0x8(%ebp),%eax
8010120c:	8b 40 10             	mov    0x10(%eax),%eax
8010120f:	89 04 24             	mov    %eax,(%esp)
80101212:	e8 a7 07 00 00       	call   801019be <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101217:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010121a:	8b 45 08             	mov    0x8(%ebp),%eax
8010121d:	8b 50 14             	mov    0x14(%eax),%edx
80101220:	8b 45 08             	mov    0x8(%ebp),%eax
80101223:	8b 40 10             	mov    0x10(%eax),%eax
80101226:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010122a:	89 54 24 08          	mov    %edx,0x8(%esp)
8010122e:	8b 55 0c             	mov    0xc(%ebp),%edx
80101231:	89 54 24 04          	mov    %edx,0x4(%esp)
80101235:	89 04 24             	mov    %eax,(%esp)
80101238:	e8 18 0c 00 00       	call   80101e55 <readi>
8010123d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101240:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101244:	7e 11                	jle    80101257 <fileread+0x9a>
      f->off += r;
80101246:	8b 45 08             	mov    0x8(%ebp),%eax
80101249:	8b 50 14             	mov    0x14(%eax),%edx
8010124c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010124f:	01 c2                	add    %eax,%edx
80101251:	8b 45 08             	mov    0x8(%ebp),%eax
80101254:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101257:	8b 45 08             	mov    0x8(%ebp),%eax
8010125a:	8b 40 10             	mov    0x10(%eax),%eax
8010125d:	89 04 24             	mov    %eax,(%esp)
80101260:	e8 63 08 00 00       	call   80101ac8 <iunlock>
    return r;
80101265:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101268:	eb 0c                	jmp    80101276 <fileread+0xb9>
  }
  panic("fileread");
8010126a:	c7 04 24 4c 88 10 80 	movl   $0x8010884c,(%esp)
80101271:	e8 de f2 ff ff       	call   80100554 <panic>
}
80101276:	c9                   	leave  
80101277:	c3                   	ret    

80101278 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101278:	55                   	push   %ebp
80101279:	89 e5                	mov    %esp,%ebp
8010127b:	53                   	push   %ebx
8010127c:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
8010127f:	8b 45 08             	mov    0x8(%ebp),%eax
80101282:	8a 40 09             	mov    0x9(%eax),%al
80101285:	84 c0                	test   %al,%al
80101287:	75 0a                	jne    80101293 <filewrite+0x1b>
    return -1;
80101289:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010128e:	e9 20 01 00 00       	jmp    801013b3 <filewrite+0x13b>
  if(f->type == FD_PIPE)
80101293:	8b 45 08             	mov    0x8(%ebp),%eax
80101296:	8b 00                	mov    (%eax),%eax
80101298:	83 f8 01             	cmp    $0x1,%eax
8010129b:	75 21                	jne    801012be <filewrite+0x46>
    return pipewrite(f->pipe, addr, n);
8010129d:	8b 45 08             	mov    0x8(%ebp),%eax
801012a0:	8b 40 0c             	mov    0xc(%eax),%eax
801012a3:	8b 55 10             	mov    0x10(%ebp),%edx
801012a6:	89 54 24 08          	mov    %edx,0x8(%esp)
801012aa:	8b 55 0c             	mov    0xc(%ebp),%edx
801012ad:	89 54 24 04          	mov    %edx,0x4(%esp)
801012b1:	89 04 24             	mov    %eax,(%esp)
801012b4:	e8 20 2c 00 00       	call   80103ed9 <pipewrite>
801012b9:	e9 f5 00 00 00       	jmp    801013b3 <filewrite+0x13b>
  if(f->type == FD_INODE){
801012be:	8b 45 08             	mov    0x8(%ebp),%eax
801012c1:	8b 00                	mov    (%eax),%eax
801012c3:	83 f8 02             	cmp    $0x2,%eax
801012c6:	0f 85 db 00 00 00    	jne    801013a7 <filewrite+0x12f>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
801012cc:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
801012d3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801012da:	e9 a8 00 00 00       	jmp    80101387 <filewrite+0x10f>
      int n1 = n - i;
801012df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012e2:	8b 55 10             	mov    0x10(%ebp),%edx
801012e5:	29 c2                	sub    %eax,%edx
801012e7:	89 d0                	mov    %edx,%eax
801012e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801012ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801012ef:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801012f2:	7e 06                	jle    801012fa <filewrite+0x82>
        n1 = max;
801012f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801012f7:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
801012fa:	e8 b8 21 00 00       	call   801034b7 <begin_op>
      ilock(f->ip);
801012ff:	8b 45 08             	mov    0x8(%ebp),%eax
80101302:	8b 40 10             	mov    0x10(%eax),%eax
80101305:	89 04 24             	mov    %eax,(%esp)
80101308:	e8 b1 06 00 00       	call   801019be <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
8010130d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101310:	8b 45 08             	mov    0x8(%ebp),%eax
80101313:	8b 50 14             	mov    0x14(%eax),%edx
80101316:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101319:	8b 45 0c             	mov    0xc(%ebp),%eax
8010131c:	01 c3                	add    %eax,%ebx
8010131e:	8b 45 08             	mov    0x8(%ebp),%eax
80101321:	8b 40 10             	mov    0x10(%eax),%eax
80101324:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101328:	89 54 24 08          	mov    %edx,0x8(%esp)
8010132c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80101330:	89 04 24             	mov    %eax,(%esp)
80101333:	e8 81 0c 00 00       	call   80101fb9 <writei>
80101338:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010133b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010133f:	7e 11                	jle    80101352 <filewrite+0xda>
        f->off += r;
80101341:	8b 45 08             	mov    0x8(%ebp),%eax
80101344:	8b 50 14             	mov    0x14(%eax),%edx
80101347:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010134a:	01 c2                	add    %eax,%edx
8010134c:	8b 45 08             	mov    0x8(%ebp),%eax
8010134f:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101352:	8b 45 08             	mov    0x8(%ebp),%eax
80101355:	8b 40 10             	mov    0x10(%eax),%eax
80101358:	89 04 24             	mov    %eax,(%esp)
8010135b:	e8 68 07 00 00       	call   80101ac8 <iunlock>
      end_op();
80101360:	e8 d4 21 00 00       	call   80103539 <end_op>

      if(r < 0)
80101365:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101369:	79 02                	jns    8010136d <filewrite+0xf5>
        break;
8010136b:	eb 26                	jmp    80101393 <filewrite+0x11b>
      if(r != n1)
8010136d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101370:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101373:	74 0c                	je     80101381 <filewrite+0x109>
        panic("short filewrite");
80101375:	c7 04 24 55 88 10 80 	movl   $0x80108855,(%esp)
8010137c:	e8 d3 f1 ff ff       	call   80100554 <panic>
      i += r;
80101381:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101384:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
80101387:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010138a:	3b 45 10             	cmp    0x10(%ebp),%eax
8010138d:	0f 8c 4c ff ff ff    	jl     801012df <filewrite+0x67>
        break;
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
80101393:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101396:	3b 45 10             	cmp    0x10(%ebp),%eax
80101399:	75 05                	jne    801013a0 <filewrite+0x128>
8010139b:	8b 45 10             	mov    0x10(%ebp),%eax
8010139e:	eb 05                	jmp    801013a5 <filewrite+0x12d>
801013a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013a5:	eb 0c                	jmp    801013b3 <filewrite+0x13b>
  }
  panic("filewrite");
801013a7:	c7 04 24 65 88 10 80 	movl   $0x80108865,(%esp)
801013ae:	e8 a1 f1 ff ff       	call   80100554 <panic>
}
801013b3:	83 c4 24             	add    $0x24,%esp
801013b6:	5b                   	pop    %ebx
801013b7:	5d                   	pop    %ebp
801013b8:	c3                   	ret    
801013b9:	00 00                	add    %al,(%eax)
	...

801013bc <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801013bc:	55                   	push   %ebp
801013bd:	89 e5                	mov    %esp,%ebp
801013bf:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;

  bp = bread(dev, 1);
801013c2:	8b 45 08             	mov    0x8(%ebp),%eax
801013c5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801013cc:	00 
801013cd:	89 04 24             	mov    %eax,(%esp)
801013d0:	e8 e0 ed ff ff       	call   801001b5 <bread>
801013d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801013d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013db:	83 c0 5c             	add    $0x5c,%eax
801013de:	c7 44 24 08 1c 00 00 	movl   $0x1c,0x8(%esp)
801013e5:	00 
801013e6:	89 44 24 04          	mov    %eax,0x4(%esp)
801013ea:	8b 45 0c             	mov    0xc(%ebp),%eax
801013ed:	89 04 24             	mov    %eax,(%esp)
801013f0:	e8 02 3d 00 00       	call   801050f7 <memmove>
  brelse(bp);
801013f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013f8:	89 04 24             	mov    %eax,(%esp)
801013fb:	e8 2c ee ff ff       	call   8010022c <brelse>
}
80101400:	c9                   	leave  
80101401:	c3                   	ret    

80101402 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101402:	55                   	push   %ebp
80101403:	89 e5                	mov    %esp,%ebp
80101405:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;

  bp = bread(dev, bno);
80101408:	8b 55 0c             	mov    0xc(%ebp),%edx
8010140b:	8b 45 08             	mov    0x8(%ebp),%eax
8010140e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101412:	89 04 24             	mov    %eax,(%esp)
80101415:	e8 9b ed ff ff       	call   801001b5 <bread>
8010141a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010141d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101420:	83 c0 5c             	add    $0x5c,%eax
80101423:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010142a:	00 
8010142b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101432:	00 
80101433:	89 04 24             	mov    %eax,(%esp)
80101436:	e8 f3 3b 00 00       	call   8010502e <memset>
  log_write(bp);
8010143b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010143e:	89 04 24             	mov    %eax,(%esp)
80101441:	e8 75 22 00 00       	call   801036bb <log_write>
  brelse(bp);
80101446:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101449:	89 04 24             	mov    %eax,(%esp)
8010144c:	e8 db ed ff ff       	call   8010022c <brelse>
}
80101451:	c9                   	leave  
80101452:	c3                   	ret    

80101453 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101453:	55                   	push   %ebp
80101454:	89 e5                	mov    %esp,%ebp
80101456:	83 ec 28             	sub    $0x28,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
80101459:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101460:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101467:	e9 03 01 00 00       	jmp    8010156f <balloc+0x11c>
    bp = bread(dev, BBLOCK(b, sb));
8010146c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010146f:	85 c0                	test   %eax,%eax
80101471:	79 05                	jns    80101478 <balloc+0x25>
80101473:	05 ff 0f 00 00       	add    $0xfff,%eax
80101478:	c1 f8 0c             	sar    $0xc,%eax
8010147b:	89 c2                	mov    %eax,%edx
8010147d:	a1 f8 1c 11 80       	mov    0x80111cf8,%eax
80101482:	01 d0                	add    %edx,%eax
80101484:	89 44 24 04          	mov    %eax,0x4(%esp)
80101488:	8b 45 08             	mov    0x8(%ebp),%eax
8010148b:	89 04 24             	mov    %eax,(%esp)
8010148e:	e8 22 ed ff ff       	call   801001b5 <bread>
80101493:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101496:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010149d:	e9 9b 00 00 00       	jmp    8010153d <balloc+0xea>
      m = 1 << (bi % 8);
801014a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014a5:	25 07 00 00 80       	and    $0x80000007,%eax
801014aa:	85 c0                	test   %eax,%eax
801014ac:	79 05                	jns    801014b3 <balloc+0x60>
801014ae:	48                   	dec    %eax
801014af:	83 c8 f8             	or     $0xfffffff8,%eax
801014b2:	40                   	inc    %eax
801014b3:	ba 01 00 00 00       	mov    $0x1,%edx
801014b8:	88 c1                	mov    %al,%cl
801014ba:	d3 e2                	shl    %cl,%edx
801014bc:	89 d0                	mov    %edx,%eax
801014be:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801014c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014c4:	85 c0                	test   %eax,%eax
801014c6:	79 03                	jns    801014cb <balloc+0x78>
801014c8:	83 c0 07             	add    $0x7,%eax
801014cb:	c1 f8 03             	sar    $0x3,%eax
801014ce:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014d1:	8a 44 02 5c          	mov    0x5c(%edx,%eax,1),%al
801014d5:	0f b6 c0             	movzbl %al,%eax
801014d8:	23 45 e8             	and    -0x18(%ebp),%eax
801014db:	85 c0                	test   %eax,%eax
801014dd:	75 5b                	jne    8010153a <balloc+0xe7>
        bp->data[bi/8] |= m;  // Mark block in use.
801014df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014e2:	85 c0                	test   %eax,%eax
801014e4:	79 03                	jns    801014e9 <balloc+0x96>
801014e6:	83 c0 07             	add    $0x7,%eax
801014e9:	c1 f8 03             	sar    $0x3,%eax
801014ec:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014ef:	8a 54 02 5c          	mov    0x5c(%edx,%eax,1),%dl
801014f3:	88 d1                	mov    %dl,%cl
801014f5:	8b 55 e8             	mov    -0x18(%ebp),%edx
801014f8:	09 ca                	or     %ecx,%edx
801014fa:	88 d1                	mov    %dl,%cl
801014fc:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014ff:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
80101503:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101506:	89 04 24             	mov    %eax,(%esp)
80101509:	e8 ad 21 00 00       	call   801036bb <log_write>
        brelse(bp);
8010150e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101511:	89 04 24             	mov    %eax,(%esp)
80101514:	e8 13 ed ff ff       	call   8010022c <brelse>
        bzero(dev, b + bi);
80101519:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010151c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010151f:	01 c2                	add    %eax,%edx
80101521:	8b 45 08             	mov    0x8(%ebp),%eax
80101524:	89 54 24 04          	mov    %edx,0x4(%esp)
80101528:	89 04 24             	mov    %eax,(%esp)
8010152b:	e8 d2 fe ff ff       	call   80101402 <bzero>
        return b + bi;
80101530:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101533:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101536:	01 d0                	add    %edx,%eax
80101538:	eb 51                	jmp    8010158b <balloc+0x138>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010153a:	ff 45 f0             	incl   -0x10(%ebp)
8010153d:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101544:	7f 17                	jg     8010155d <balloc+0x10a>
80101546:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101549:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010154c:	01 d0                	add    %edx,%eax
8010154e:	89 c2                	mov    %eax,%edx
80101550:	a1 e0 1c 11 80       	mov    0x80111ce0,%eax
80101555:	39 c2                	cmp    %eax,%edx
80101557:	0f 82 45 ff ff ff    	jb     801014a2 <balloc+0x4f>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
8010155d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101560:	89 04 24             	mov    %eax,(%esp)
80101563:	e8 c4 ec ff ff       	call   8010022c <brelse>
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
80101568:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010156f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101572:	a1 e0 1c 11 80       	mov    0x80111ce0,%eax
80101577:	39 c2                	cmp    %eax,%edx
80101579:	0f 82 ed fe ff ff    	jb     8010146c <balloc+0x19>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
8010157f:	c7 04 24 70 88 10 80 	movl   $0x80108870,(%esp)
80101586:	e8 c9 ef ff ff       	call   80100554 <panic>
}
8010158b:	c9                   	leave  
8010158c:	c3                   	ret    

8010158d <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
8010158d:	55                   	push   %ebp
8010158e:	89 e5                	mov    %esp,%ebp
80101590:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
80101593:	c7 44 24 04 e0 1c 11 	movl   $0x80111ce0,0x4(%esp)
8010159a:	80 
8010159b:	8b 45 08             	mov    0x8(%ebp),%eax
8010159e:	89 04 24             	mov    %eax,(%esp)
801015a1:	e8 16 fe ff ff       	call   801013bc <readsb>
  bp = bread(dev, BBLOCK(b, sb));
801015a6:	8b 45 0c             	mov    0xc(%ebp),%eax
801015a9:	c1 e8 0c             	shr    $0xc,%eax
801015ac:	89 c2                	mov    %eax,%edx
801015ae:	a1 f8 1c 11 80       	mov    0x80111cf8,%eax
801015b3:	01 c2                	add    %eax,%edx
801015b5:	8b 45 08             	mov    0x8(%ebp),%eax
801015b8:	89 54 24 04          	mov    %edx,0x4(%esp)
801015bc:	89 04 24             	mov    %eax,(%esp)
801015bf:	e8 f1 eb ff ff       	call   801001b5 <bread>
801015c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801015c7:	8b 45 0c             	mov    0xc(%ebp),%eax
801015ca:	25 ff 0f 00 00       	and    $0xfff,%eax
801015cf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801015d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015d5:	25 07 00 00 80       	and    $0x80000007,%eax
801015da:	85 c0                	test   %eax,%eax
801015dc:	79 05                	jns    801015e3 <bfree+0x56>
801015de:	48                   	dec    %eax
801015df:	83 c8 f8             	or     $0xfffffff8,%eax
801015e2:	40                   	inc    %eax
801015e3:	ba 01 00 00 00       	mov    $0x1,%edx
801015e8:	88 c1                	mov    %al,%cl
801015ea:	d3 e2                	shl    %cl,%edx
801015ec:	89 d0                	mov    %edx,%eax
801015ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801015f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015f4:	85 c0                	test   %eax,%eax
801015f6:	79 03                	jns    801015fb <bfree+0x6e>
801015f8:	83 c0 07             	add    $0x7,%eax
801015fb:	c1 f8 03             	sar    $0x3,%eax
801015fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101601:	8a 44 02 5c          	mov    0x5c(%edx,%eax,1),%al
80101605:	0f b6 c0             	movzbl %al,%eax
80101608:	23 45 ec             	and    -0x14(%ebp),%eax
8010160b:	85 c0                	test   %eax,%eax
8010160d:	75 0c                	jne    8010161b <bfree+0x8e>
    panic("freeing free block");
8010160f:	c7 04 24 86 88 10 80 	movl   $0x80108886,(%esp)
80101616:	e8 39 ef ff ff       	call   80100554 <panic>
  bp->data[bi/8] &= ~m;
8010161b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010161e:	85 c0                	test   %eax,%eax
80101620:	79 03                	jns    80101625 <bfree+0x98>
80101622:	83 c0 07             	add    $0x7,%eax
80101625:	c1 f8 03             	sar    $0x3,%eax
80101628:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010162b:	8a 54 02 5c          	mov    0x5c(%edx,%eax,1),%dl
8010162f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80101632:	f7 d1                	not    %ecx
80101634:	21 ca                	and    %ecx,%edx
80101636:	88 d1                	mov    %dl,%cl
80101638:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010163b:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
8010163f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101642:	89 04 24             	mov    %eax,(%esp)
80101645:	e8 71 20 00 00       	call   801036bb <log_write>
  brelse(bp);
8010164a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010164d:	89 04 24             	mov    %eax,(%esp)
80101650:	e8 d7 eb ff ff       	call   8010022c <brelse>
}
80101655:	c9                   	leave  
80101656:	c3                   	ret    

80101657 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101657:	55                   	push   %ebp
80101658:	89 e5                	mov    %esp,%ebp
8010165a:	57                   	push   %edi
8010165b:	56                   	push   %esi
8010165c:	53                   	push   %ebx
8010165d:	83 ec 4c             	sub    $0x4c,%esp
  int i = 0;
80101660:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
80101667:	c7 44 24 04 99 88 10 	movl   $0x80108899,0x4(%esp)
8010166e:	80 
8010166f:	c7 04 24 00 1d 11 80 	movl   $0x80111d00,(%esp)
80101676:	e8 2f 37 00 00       	call   80104daa <initlock>
  for(i = 0; i < NINODE; i++) {
8010167b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101682:	eb 2b                	jmp    801016af <iinit+0x58>
    initsleeplock(&icache.inode[i].lock, "inode");
80101684:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101687:	89 d0                	mov    %edx,%eax
80101689:	c1 e0 03             	shl    $0x3,%eax
8010168c:	01 d0                	add    %edx,%eax
8010168e:	c1 e0 04             	shl    $0x4,%eax
80101691:	83 c0 30             	add    $0x30,%eax
80101694:	05 00 1d 11 80       	add    $0x80111d00,%eax
80101699:	83 c0 10             	add    $0x10,%eax
8010169c:	c7 44 24 04 a0 88 10 	movl   $0x801088a0,0x4(%esp)
801016a3:	80 
801016a4:	89 04 24             	mov    %eax,(%esp)
801016a7:	e8 c0 35 00 00       	call   80104c6c <initsleeplock>
iinit(int dev)
{
  int i = 0;
  
  initlock(&icache.lock, "icache");
  for(i = 0; i < NINODE; i++) {
801016ac:	ff 45 e4             	incl   -0x1c(%ebp)
801016af:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801016b3:	7e cf                	jle    80101684 <iinit+0x2d>
    initsleeplock(&icache.inode[i].lock, "inode");
  }

  readsb(dev, &sb);
801016b5:	c7 44 24 04 e0 1c 11 	movl   $0x80111ce0,0x4(%esp)
801016bc:	80 
801016bd:	8b 45 08             	mov    0x8(%ebp),%eax
801016c0:	89 04 24             	mov    %eax,(%esp)
801016c3:	e8 f4 fc ff ff       	call   801013bc <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801016c8:	a1 f8 1c 11 80       	mov    0x80111cf8,%eax
801016cd:	8b 3d f4 1c 11 80    	mov    0x80111cf4,%edi
801016d3:	8b 35 f0 1c 11 80    	mov    0x80111cf0,%esi
801016d9:	8b 1d ec 1c 11 80    	mov    0x80111cec,%ebx
801016df:	8b 0d e8 1c 11 80    	mov    0x80111ce8,%ecx
801016e5:	8b 15 e4 1c 11 80    	mov    0x80111ce4,%edx
801016eb:	89 55 d4             	mov    %edx,-0x2c(%ebp)
801016ee:	8b 15 e0 1c 11 80    	mov    0x80111ce0,%edx
801016f4:	89 44 24 1c          	mov    %eax,0x1c(%esp)
801016f8:	89 7c 24 18          	mov    %edi,0x18(%esp)
801016fc:	89 74 24 14          	mov    %esi,0x14(%esp)
80101700:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80101704:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101708:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010170b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010170f:	89 d0                	mov    %edx,%eax
80101711:	89 44 24 04          	mov    %eax,0x4(%esp)
80101715:	c7 04 24 a8 88 10 80 	movl   $0x801088a8,(%esp)
8010171c:	e8 a0 ec ff ff       	call   801003c1 <cprintf>
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
80101721:	83 c4 4c             	add    $0x4c,%esp
80101724:	5b                   	pop    %ebx
80101725:	5e                   	pop    %esi
80101726:	5f                   	pop    %edi
80101727:	5d                   	pop    %ebp
80101728:	c3                   	ret    

80101729 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
80101729:	55                   	push   %ebp
8010172a:	89 e5                	mov    %esp,%ebp
8010172c:	83 ec 28             	sub    $0x28,%esp
8010172f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101732:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101736:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
8010173d:	e9 9b 00 00 00       	jmp    801017dd <ialloc+0xb4>
    bp = bread(dev, IBLOCK(inum, sb));
80101742:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101745:	c1 e8 03             	shr    $0x3,%eax
80101748:	89 c2                	mov    %eax,%edx
8010174a:	a1 f4 1c 11 80       	mov    0x80111cf4,%eax
8010174f:	01 d0                	add    %edx,%eax
80101751:	89 44 24 04          	mov    %eax,0x4(%esp)
80101755:	8b 45 08             	mov    0x8(%ebp),%eax
80101758:	89 04 24             	mov    %eax,(%esp)
8010175b:	e8 55 ea ff ff       	call   801001b5 <bread>
80101760:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101763:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101766:	8d 50 5c             	lea    0x5c(%eax),%edx
80101769:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010176c:	83 e0 07             	and    $0x7,%eax
8010176f:	c1 e0 06             	shl    $0x6,%eax
80101772:	01 d0                	add    %edx,%eax
80101774:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101777:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010177a:	8b 00                	mov    (%eax),%eax
8010177c:	66 85 c0             	test   %ax,%ax
8010177f:	75 4e                	jne    801017cf <ialloc+0xa6>
      memset(dip, 0, sizeof(*dip));
80101781:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
80101788:	00 
80101789:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101790:	00 
80101791:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101794:	89 04 24             	mov    %eax,(%esp)
80101797:	e8 92 38 00 00       	call   8010502e <memset>
      dip->type = type;
8010179c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010179f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801017a2:	66 89 02             	mov    %ax,(%edx)
      log_write(bp);   // mark it allocated on the disk
801017a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017a8:	89 04 24             	mov    %eax,(%esp)
801017ab:	e8 0b 1f 00 00       	call   801036bb <log_write>
      brelse(bp);
801017b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017b3:	89 04 24             	mov    %eax,(%esp)
801017b6:	e8 71 ea ff ff       	call   8010022c <brelse>
      return iget(dev, inum);
801017bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017be:	89 44 24 04          	mov    %eax,0x4(%esp)
801017c2:	8b 45 08             	mov    0x8(%ebp),%eax
801017c5:	89 04 24             	mov    %eax,(%esp)
801017c8:	e8 ea 00 00 00       	call   801018b7 <iget>
801017cd:	eb 2a                	jmp    801017f9 <ialloc+0xd0>
    }
    brelse(bp);
801017cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017d2:	89 04 24             	mov    %eax,(%esp)
801017d5:	e8 52 ea ff ff       	call   8010022c <brelse>
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801017da:	ff 45 f4             	incl   -0xc(%ebp)
801017dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801017e0:	a1 e8 1c 11 80       	mov    0x80111ce8,%eax
801017e5:	39 c2                	cmp    %eax,%edx
801017e7:	0f 82 55 ff ff ff    	jb     80101742 <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
801017ed:	c7 04 24 fb 88 10 80 	movl   $0x801088fb,(%esp)
801017f4:	e8 5b ed ff ff       	call   80100554 <panic>
}
801017f9:	c9                   	leave  
801017fa:	c3                   	ret    

801017fb <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
801017fb:	55                   	push   %ebp
801017fc:	89 e5                	mov    %esp,%ebp
801017fe:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101801:	8b 45 08             	mov    0x8(%ebp),%eax
80101804:	8b 40 04             	mov    0x4(%eax),%eax
80101807:	c1 e8 03             	shr    $0x3,%eax
8010180a:	89 c2                	mov    %eax,%edx
8010180c:	a1 f4 1c 11 80       	mov    0x80111cf4,%eax
80101811:	01 c2                	add    %eax,%edx
80101813:	8b 45 08             	mov    0x8(%ebp),%eax
80101816:	8b 00                	mov    (%eax),%eax
80101818:	89 54 24 04          	mov    %edx,0x4(%esp)
8010181c:	89 04 24             	mov    %eax,(%esp)
8010181f:	e8 91 e9 ff ff       	call   801001b5 <bread>
80101824:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101827:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010182a:	8d 50 5c             	lea    0x5c(%eax),%edx
8010182d:	8b 45 08             	mov    0x8(%ebp),%eax
80101830:	8b 40 04             	mov    0x4(%eax),%eax
80101833:	83 e0 07             	and    $0x7,%eax
80101836:	c1 e0 06             	shl    $0x6,%eax
80101839:	01 d0                	add    %edx,%eax
8010183b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
8010183e:	8b 45 08             	mov    0x8(%ebp),%eax
80101841:	8b 40 50             	mov    0x50(%eax),%eax
80101844:	8b 55 f0             	mov    -0x10(%ebp),%edx
80101847:	66 89 02             	mov    %ax,(%edx)
  dip->major = ip->major;
8010184a:	8b 45 08             	mov    0x8(%ebp),%eax
8010184d:	66 8b 40 52          	mov    0x52(%eax),%ax
80101851:	8b 55 f0             	mov    -0x10(%ebp),%edx
80101854:	66 89 42 02          	mov    %ax,0x2(%edx)
  dip->minor = ip->minor;
80101858:	8b 45 08             	mov    0x8(%ebp),%eax
8010185b:	8b 40 54             	mov    0x54(%eax),%eax
8010185e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80101861:	66 89 42 04          	mov    %ax,0x4(%edx)
  dip->nlink = ip->nlink;
80101865:	8b 45 08             	mov    0x8(%ebp),%eax
80101868:	66 8b 40 56          	mov    0x56(%eax),%ax
8010186c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010186f:	66 89 42 06          	mov    %ax,0x6(%edx)
  dip->size = ip->size;
80101873:	8b 45 08             	mov    0x8(%ebp),%eax
80101876:	8b 50 58             	mov    0x58(%eax),%edx
80101879:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010187c:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010187f:	8b 45 08             	mov    0x8(%ebp),%eax
80101882:	8d 50 5c             	lea    0x5c(%eax),%edx
80101885:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101888:	83 c0 0c             	add    $0xc,%eax
8010188b:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101892:	00 
80101893:	89 54 24 04          	mov    %edx,0x4(%esp)
80101897:	89 04 24             	mov    %eax,(%esp)
8010189a:	e8 58 38 00 00       	call   801050f7 <memmove>
  log_write(bp);
8010189f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018a2:	89 04 24             	mov    %eax,(%esp)
801018a5:	e8 11 1e 00 00       	call   801036bb <log_write>
  brelse(bp);
801018aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ad:	89 04 24             	mov    %eax,(%esp)
801018b0:	e8 77 e9 ff ff       	call   8010022c <brelse>
}
801018b5:	c9                   	leave  
801018b6:	c3                   	ret    

801018b7 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801018b7:	55                   	push   %ebp
801018b8:	89 e5                	mov    %esp,%ebp
801018ba:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801018bd:	c7 04 24 00 1d 11 80 	movl   $0x80111d00,(%esp)
801018c4:	e8 02 35 00 00       	call   80104dcb <acquire>

  // Is the inode already cached?
  empty = 0;
801018c9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018d0:	c7 45 f4 34 1d 11 80 	movl   $0x80111d34,-0xc(%ebp)
801018d7:	eb 5c                	jmp    80101935 <iget+0x7e>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801018d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018dc:	8b 40 08             	mov    0x8(%eax),%eax
801018df:	85 c0                	test   %eax,%eax
801018e1:	7e 35                	jle    80101918 <iget+0x61>
801018e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018e6:	8b 00                	mov    (%eax),%eax
801018e8:	3b 45 08             	cmp    0x8(%ebp),%eax
801018eb:	75 2b                	jne    80101918 <iget+0x61>
801018ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018f0:	8b 40 04             	mov    0x4(%eax),%eax
801018f3:	3b 45 0c             	cmp    0xc(%ebp),%eax
801018f6:	75 20                	jne    80101918 <iget+0x61>
      ip->ref++;
801018f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018fb:	8b 40 08             	mov    0x8(%eax),%eax
801018fe:	8d 50 01             	lea    0x1(%eax),%edx
80101901:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101904:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101907:	c7 04 24 00 1d 11 80 	movl   $0x80111d00,(%esp)
8010190e:	e8 22 35 00 00       	call   80104e35 <release>
      return ip;
80101913:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101916:	eb 72                	jmp    8010198a <iget+0xd3>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101918:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010191c:	75 10                	jne    8010192e <iget+0x77>
8010191e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101921:	8b 40 08             	mov    0x8(%eax),%eax
80101924:	85 c0                	test   %eax,%eax
80101926:	75 06                	jne    8010192e <iget+0x77>
      empty = ip;
80101928:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010192b:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010192e:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101935:	81 7d f4 54 39 11 80 	cmpl   $0x80113954,-0xc(%ebp)
8010193c:	72 9b                	jb     801018d9 <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
8010193e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101942:	75 0c                	jne    80101950 <iget+0x99>
    panic("iget: no inodes");
80101944:	c7 04 24 0d 89 10 80 	movl   $0x8010890d,(%esp)
8010194b:	e8 04 ec ff ff       	call   80100554 <panic>

  ip = empty;
80101950:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101953:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101956:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101959:	8b 55 08             	mov    0x8(%ebp),%edx
8010195c:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
8010195e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101961:	8b 55 0c             	mov    0xc(%ebp),%edx
80101964:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101967:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010196a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101971:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101974:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
8010197b:	c7 04 24 00 1d 11 80 	movl   $0x80111d00,(%esp)
80101982:	e8 ae 34 00 00       	call   80104e35 <release>

  return ip;
80101987:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010198a:	c9                   	leave  
8010198b:	c3                   	ret    

8010198c <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
8010198c:	55                   	push   %ebp
8010198d:	89 e5                	mov    %esp,%ebp
8010198f:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101992:	c7 04 24 00 1d 11 80 	movl   $0x80111d00,(%esp)
80101999:	e8 2d 34 00 00       	call   80104dcb <acquire>
  ip->ref++;
8010199e:	8b 45 08             	mov    0x8(%ebp),%eax
801019a1:	8b 40 08             	mov    0x8(%eax),%eax
801019a4:	8d 50 01             	lea    0x1(%eax),%edx
801019a7:	8b 45 08             	mov    0x8(%ebp),%eax
801019aa:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801019ad:	c7 04 24 00 1d 11 80 	movl   $0x80111d00,(%esp)
801019b4:	e8 7c 34 00 00       	call   80104e35 <release>
  return ip;
801019b9:	8b 45 08             	mov    0x8(%ebp),%eax
}
801019bc:	c9                   	leave  
801019bd:	c3                   	ret    

801019be <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
801019be:	55                   	push   %ebp
801019bf:	89 e5                	mov    %esp,%ebp
801019c1:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
801019c4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801019c8:	74 0a                	je     801019d4 <ilock+0x16>
801019ca:	8b 45 08             	mov    0x8(%ebp),%eax
801019cd:	8b 40 08             	mov    0x8(%eax),%eax
801019d0:	85 c0                	test   %eax,%eax
801019d2:	7f 0c                	jg     801019e0 <ilock+0x22>
    panic("ilock");
801019d4:	c7 04 24 1d 89 10 80 	movl   $0x8010891d,(%esp)
801019db:	e8 74 eb ff ff       	call   80100554 <panic>

  acquiresleep(&ip->lock);
801019e0:	8b 45 08             	mov    0x8(%ebp),%eax
801019e3:	83 c0 0c             	add    $0xc,%eax
801019e6:	89 04 24             	mov    %eax,(%esp)
801019e9:	e8 b8 32 00 00       	call   80104ca6 <acquiresleep>

  if(ip->valid == 0){
801019ee:	8b 45 08             	mov    0x8(%ebp),%eax
801019f1:	8b 40 4c             	mov    0x4c(%eax),%eax
801019f4:	85 c0                	test   %eax,%eax
801019f6:	0f 85 ca 00 00 00    	jne    80101ac6 <ilock+0x108>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801019fc:	8b 45 08             	mov    0x8(%ebp),%eax
801019ff:	8b 40 04             	mov    0x4(%eax),%eax
80101a02:	c1 e8 03             	shr    $0x3,%eax
80101a05:	89 c2                	mov    %eax,%edx
80101a07:	a1 f4 1c 11 80       	mov    0x80111cf4,%eax
80101a0c:	01 c2                	add    %eax,%edx
80101a0e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a11:	8b 00                	mov    (%eax),%eax
80101a13:	89 54 24 04          	mov    %edx,0x4(%esp)
80101a17:	89 04 24             	mov    %eax,(%esp)
80101a1a:	e8 96 e7 ff ff       	call   801001b5 <bread>
80101a1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a25:	8d 50 5c             	lea    0x5c(%eax),%edx
80101a28:	8b 45 08             	mov    0x8(%ebp),%eax
80101a2b:	8b 40 04             	mov    0x4(%eax),%eax
80101a2e:	83 e0 07             	and    $0x7,%eax
80101a31:	c1 e0 06             	shl    $0x6,%eax
80101a34:	01 d0                	add    %edx,%eax
80101a36:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101a39:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a3c:	8b 00                	mov    (%eax),%eax
80101a3e:	8b 55 08             	mov    0x8(%ebp),%edx
80101a41:	66 89 42 50          	mov    %ax,0x50(%edx)
    ip->major = dip->major;
80101a45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a48:	66 8b 40 02          	mov    0x2(%eax),%ax
80101a4c:	8b 55 08             	mov    0x8(%ebp),%edx
80101a4f:	66 89 42 52          	mov    %ax,0x52(%edx)
    ip->minor = dip->minor;
80101a53:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a56:	8b 40 04             	mov    0x4(%eax),%eax
80101a59:	8b 55 08             	mov    0x8(%ebp),%edx
80101a5c:	66 89 42 54          	mov    %ax,0x54(%edx)
    ip->nlink = dip->nlink;
80101a60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a63:	66 8b 40 06          	mov    0x6(%eax),%ax
80101a67:	8b 55 08             	mov    0x8(%ebp),%edx
80101a6a:	66 89 42 56          	mov    %ax,0x56(%edx)
    ip->size = dip->size;
80101a6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a71:	8b 50 08             	mov    0x8(%eax),%edx
80101a74:	8b 45 08             	mov    0x8(%ebp),%eax
80101a77:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101a7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a7d:	8d 50 0c             	lea    0xc(%eax),%edx
80101a80:	8b 45 08             	mov    0x8(%ebp),%eax
80101a83:	83 c0 5c             	add    $0x5c,%eax
80101a86:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101a8d:	00 
80101a8e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101a92:	89 04 24             	mov    %eax,(%esp)
80101a95:	e8 5d 36 00 00       	call   801050f7 <memmove>
    brelse(bp);
80101a9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a9d:	89 04 24             	mov    %eax,(%esp)
80101aa0:	e8 87 e7 ff ff       	call   8010022c <brelse>
    ip->valid = 1;
80101aa5:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa8:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101aaf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab2:	8b 40 50             	mov    0x50(%eax),%eax
80101ab5:	66 85 c0             	test   %ax,%ax
80101ab8:	75 0c                	jne    80101ac6 <ilock+0x108>
      panic("ilock: no type");
80101aba:	c7 04 24 23 89 10 80 	movl   $0x80108923,(%esp)
80101ac1:	e8 8e ea ff ff       	call   80100554 <panic>
  }
}
80101ac6:	c9                   	leave  
80101ac7:	c3                   	ret    

80101ac8 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101ac8:	55                   	push   %ebp
80101ac9:	89 e5                	mov    %esp,%ebp
80101acb:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101ace:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101ad2:	74 1c                	je     80101af0 <iunlock+0x28>
80101ad4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad7:	83 c0 0c             	add    $0xc,%eax
80101ada:	89 04 24             	mov    %eax,(%esp)
80101add:	e8 61 32 00 00       	call   80104d43 <holdingsleep>
80101ae2:	85 c0                	test   %eax,%eax
80101ae4:	74 0a                	je     80101af0 <iunlock+0x28>
80101ae6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae9:	8b 40 08             	mov    0x8(%eax),%eax
80101aec:	85 c0                	test   %eax,%eax
80101aee:	7f 0c                	jg     80101afc <iunlock+0x34>
    panic("iunlock");
80101af0:	c7 04 24 32 89 10 80 	movl   $0x80108932,(%esp)
80101af7:	e8 58 ea ff ff       	call   80100554 <panic>

  releasesleep(&ip->lock);
80101afc:	8b 45 08             	mov    0x8(%ebp),%eax
80101aff:	83 c0 0c             	add    $0xc,%eax
80101b02:	89 04 24             	mov    %eax,(%esp)
80101b05:	e8 f7 31 00 00       	call   80104d01 <releasesleep>
}
80101b0a:	c9                   	leave  
80101b0b:	c3                   	ret    

80101b0c <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b0c:	55                   	push   %ebp
80101b0d:	89 e5                	mov    %esp,%ebp
80101b0f:	83 ec 28             	sub    $0x28,%esp
  acquiresleep(&ip->lock);
80101b12:	8b 45 08             	mov    0x8(%ebp),%eax
80101b15:	83 c0 0c             	add    $0xc,%eax
80101b18:	89 04 24             	mov    %eax,(%esp)
80101b1b:	e8 86 31 00 00       	call   80104ca6 <acquiresleep>
  if(ip->valid && ip->nlink == 0){
80101b20:	8b 45 08             	mov    0x8(%ebp),%eax
80101b23:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b26:	85 c0                	test   %eax,%eax
80101b28:	74 5c                	je     80101b86 <iput+0x7a>
80101b2a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b2d:	66 8b 40 56          	mov    0x56(%eax),%ax
80101b31:	66 85 c0             	test   %ax,%ax
80101b34:	75 50                	jne    80101b86 <iput+0x7a>
    acquire(&icache.lock);
80101b36:	c7 04 24 00 1d 11 80 	movl   $0x80111d00,(%esp)
80101b3d:	e8 89 32 00 00       	call   80104dcb <acquire>
    int r = ip->ref;
80101b42:	8b 45 08             	mov    0x8(%ebp),%eax
80101b45:	8b 40 08             	mov    0x8(%eax),%eax
80101b48:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101b4b:	c7 04 24 00 1d 11 80 	movl   $0x80111d00,(%esp)
80101b52:	e8 de 32 00 00       	call   80104e35 <release>
    if(r == 1){
80101b57:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101b5b:	75 29                	jne    80101b86 <iput+0x7a>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101b5d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b60:	89 04 24             	mov    %eax,(%esp)
80101b63:	e8 86 01 00 00       	call   80101cee <itrunc>
      ip->type = 0;
80101b68:	8b 45 08             	mov    0x8(%ebp),%eax
80101b6b:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101b71:	8b 45 08             	mov    0x8(%ebp),%eax
80101b74:	89 04 24             	mov    %eax,(%esp)
80101b77:	e8 7f fc ff ff       	call   801017fb <iupdate>
      ip->valid = 0;
80101b7c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b7f:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101b86:	8b 45 08             	mov    0x8(%ebp),%eax
80101b89:	83 c0 0c             	add    $0xc,%eax
80101b8c:	89 04 24             	mov    %eax,(%esp)
80101b8f:	e8 6d 31 00 00       	call   80104d01 <releasesleep>

  acquire(&icache.lock);
80101b94:	c7 04 24 00 1d 11 80 	movl   $0x80111d00,(%esp)
80101b9b:	e8 2b 32 00 00       	call   80104dcb <acquire>
  ip->ref--;
80101ba0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba3:	8b 40 08             	mov    0x8(%eax),%eax
80101ba6:	8d 50 ff             	lea    -0x1(%eax),%edx
80101ba9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bac:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101baf:	c7 04 24 00 1d 11 80 	movl   $0x80111d00,(%esp)
80101bb6:	e8 7a 32 00 00       	call   80104e35 <release>
}
80101bbb:	c9                   	leave  
80101bbc:	c3                   	ret    

80101bbd <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101bbd:	55                   	push   %ebp
80101bbe:	89 e5                	mov    %esp,%ebp
80101bc0:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101bc3:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc6:	89 04 24             	mov    %eax,(%esp)
80101bc9:	e8 fa fe ff ff       	call   80101ac8 <iunlock>
  iput(ip);
80101bce:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd1:	89 04 24             	mov    %eax,(%esp)
80101bd4:	e8 33 ff ff ff       	call   80101b0c <iput>
}
80101bd9:	c9                   	leave  
80101bda:	c3                   	ret    

80101bdb <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101bdb:	55                   	push   %ebp
80101bdc:	89 e5                	mov    %esp,%ebp
80101bde:	53                   	push   %ebx
80101bdf:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101be2:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101be6:	77 3e                	ja     80101c26 <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101be8:	8b 45 08             	mov    0x8(%ebp),%eax
80101beb:	8b 55 0c             	mov    0xc(%ebp),%edx
80101bee:	83 c2 14             	add    $0x14,%edx
80101bf1:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101bf5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bf8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101bfc:	75 20                	jne    80101c1e <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101bfe:	8b 45 08             	mov    0x8(%ebp),%eax
80101c01:	8b 00                	mov    (%eax),%eax
80101c03:	89 04 24             	mov    %eax,(%esp)
80101c06:	e8 48 f8 ff ff       	call   80101453 <balloc>
80101c0b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c0e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c11:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c14:	8d 4a 14             	lea    0x14(%edx),%ecx
80101c17:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c1a:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101c1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c21:	e9 c2 00 00 00       	jmp    80101ce8 <bmap+0x10d>
  }
  bn -= NDIRECT;
80101c26:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101c2a:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101c2e:	0f 87 a8 00 00 00    	ja     80101cdc <bmap+0x101>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101c34:	8b 45 08             	mov    0x8(%ebp),%eax
80101c37:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101c3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c40:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c44:	75 1c                	jne    80101c62 <bmap+0x87>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101c46:	8b 45 08             	mov    0x8(%ebp),%eax
80101c49:	8b 00                	mov    (%eax),%eax
80101c4b:	89 04 24             	mov    %eax,(%esp)
80101c4e:	e8 00 f8 ff ff       	call   80101453 <balloc>
80101c53:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c56:	8b 45 08             	mov    0x8(%ebp),%eax
80101c59:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c5c:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101c62:	8b 45 08             	mov    0x8(%ebp),%eax
80101c65:	8b 00                	mov    (%eax),%eax
80101c67:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c6a:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c6e:	89 04 24             	mov    %eax,(%esp)
80101c71:	e8 3f e5 ff ff       	call   801001b5 <bread>
80101c76:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101c79:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c7c:	83 c0 5c             	add    $0x5c,%eax
80101c7f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101c82:	8b 45 0c             	mov    0xc(%ebp),%eax
80101c85:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101c8c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101c8f:	01 d0                	add    %edx,%eax
80101c91:	8b 00                	mov    (%eax),%eax
80101c93:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c96:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c9a:	75 30                	jne    80101ccc <bmap+0xf1>
      a[bn] = addr = balloc(ip->dev);
80101c9c:	8b 45 0c             	mov    0xc(%ebp),%eax
80101c9f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ca6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ca9:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101cac:	8b 45 08             	mov    0x8(%ebp),%eax
80101caf:	8b 00                	mov    (%eax),%eax
80101cb1:	89 04 24             	mov    %eax,(%esp)
80101cb4:	e8 9a f7 ff ff       	call   80101453 <balloc>
80101cb9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101cbf:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101cc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cc4:	89 04 24             	mov    %eax,(%esp)
80101cc7:	e8 ef 19 00 00       	call   801036bb <log_write>
    }
    brelse(bp);
80101ccc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ccf:	89 04 24             	mov    %eax,(%esp)
80101cd2:	e8 55 e5 ff ff       	call   8010022c <brelse>
    return addr;
80101cd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101cda:	eb 0c                	jmp    80101ce8 <bmap+0x10d>
  }

  panic("bmap: out of range");
80101cdc:	c7 04 24 3a 89 10 80 	movl   $0x8010893a,(%esp)
80101ce3:	e8 6c e8 ff ff       	call   80100554 <panic>
}
80101ce8:	83 c4 24             	add    $0x24,%esp
80101ceb:	5b                   	pop    %ebx
80101cec:	5d                   	pop    %ebp
80101ced:	c3                   	ret    

80101cee <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101cee:	55                   	push   %ebp
80101cef:	89 e5                	mov    %esp,%ebp
80101cf1:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101cf4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101cfb:	eb 43                	jmp    80101d40 <itrunc+0x52>
    if(ip->addrs[i]){
80101cfd:	8b 45 08             	mov    0x8(%ebp),%eax
80101d00:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d03:	83 c2 14             	add    $0x14,%edx
80101d06:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d0a:	85 c0                	test   %eax,%eax
80101d0c:	74 2f                	je     80101d3d <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101d0e:	8b 45 08             	mov    0x8(%ebp),%eax
80101d11:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d14:	83 c2 14             	add    $0x14,%edx
80101d17:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101d1b:	8b 45 08             	mov    0x8(%ebp),%eax
80101d1e:	8b 00                	mov    (%eax),%eax
80101d20:	89 54 24 04          	mov    %edx,0x4(%esp)
80101d24:	89 04 24             	mov    %eax,(%esp)
80101d27:	e8 61 f8 ff ff       	call   8010158d <bfree>
      ip->addrs[i] = 0;
80101d2c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d2f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d32:	83 c2 14             	add    $0x14,%edx
80101d35:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101d3c:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d3d:	ff 45 f4             	incl   -0xc(%ebp)
80101d40:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101d44:	7e b7                	jle    80101cfd <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }

  if(ip->addrs[NDIRECT]){
80101d46:	8b 45 08             	mov    0x8(%ebp),%eax
80101d49:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101d4f:	85 c0                	test   %eax,%eax
80101d51:	0f 84 a3 00 00 00    	je     80101dfa <itrunc+0x10c>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101d57:	8b 45 08             	mov    0x8(%ebp),%eax
80101d5a:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101d60:	8b 45 08             	mov    0x8(%ebp),%eax
80101d63:	8b 00                	mov    (%eax),%eax
80101d65:	89 54 24 04          	mov    %edx,0x4(%esp)
80101d69:	89 04 24             	mov    %eax,(%esp)
80101d6c:	e8 44 e4 ff ff       	call   801001b5 <bread>
80101d71:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101d74:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d77:	83 c0 5c             	add    $0x5c,%eax
80101d7a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101d7d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101d84:	eb 3a                	jmp    80101dc0 <itrunc+0xd2>
      if(a[j])
80101d86:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d89:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d90:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101d93:	01 d0                	add    %edx,%eax
80101d95:	8b 00                	mov    (%eax),%eax
80101d97:	85 c0                	test   %eax,%eax
80101d99:	74 22                	je     80101dbd <itrunc+0xcf>
        bfree(ip->dev, a[j]);
80101d9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d9e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101da5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101da8:	01 d0                	add    %edx,%eax
80101daa:	8b 10                	mov    (%eax),%edx
80101dac:	8b 45 08             	mov    0x8(%ebp),%eax
80101daf:	8b 00                	mov    (%eax),%eax
80101db1:	89 54 24 04          	mov    %edx,0x4(%esp)
80101db5:	89 04 24             	mov    %eax,(%esp)
80101db8:	e8 d0 f7 ff ff       	call   8010158d <bfree>
  }

  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101dbd:	ff 45 f0             	incl   -0x10(%ebp)
80101dc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101dc3:	83 f8 7f             	cmp    $0x7f,%eax
80101dc6:	76 be                	jbe    80101d86 <itrunc+0x98>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101dc8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101dcb:	89 04 24             	mov    %eax,(%esp)
80101dce:	e8 59 e4 ff ff       	call   8010022c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101dd3:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd6:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101ddc:	8b 45 08             	mov    0x8(%ebp),%eax
80101ddf:	8b 00                	mov    (%eax),%eax
80101de1:	89 54 24 04          	mov    %edx,0x4(%esp)
80101de5:	89 04 24             	mov    %eax,(%esp)
80101de8:	e8 a0 f7 ff ff       	call   8010158d <bfree>
    ip->addrs[NDIRECT] = 0;
80101ded:	8b 45 08             	mov    0x8(%ebp),%eax
80101df0:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101df7:	00 00 00 
  }

  ip->size = 0;
80101dfa:	8b 45 08             	mov    0x8(%ebp),%eax
80101dfd:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101e04:	8b 45 08             	mov    0x8(%ebp),%eax
80101e07:	89 04 24             	mov    %eax,(%esp)
80101e0a:	e8 ec f9 ff ff       	call   801017fb <iupdate>
}
80101e0f:	c9                   	leave  
80101e10:	c3                   	ret    

80101e11 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101e11:	55                   	push   %ebp
80101e12:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101e14:	8b 45 08             	mov    0x8(%ebp),%eax
80101e17:	8b 00                	mov    (%eax),%eax
80101e19:	89 c2                	mov    %eax,%edx
80101e1b:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e1e:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101e21:	8b 45 08             	mov    0x8(%ebp),%eax
80101e24:	8b 50 04             	mov    0x4(%eax),%edx
80101e27:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e2a:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101e2d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e30:	8b 40 50             	mov    0x50(%eax),%eax
80101e33:	8b 55 0c             	mov    0xc(%ebp),%edx
80101e36:	66 89 02             	mov    %ax,(%edx)
  st->nlink = ip->nlink;
80101e39:	8b 45 08             	mov    0x8(%ebp),%eax
80101e3c:	66 8b 40 56          	mov    0x56(%eax),%ax
80101e40:	8b 55 0c             	mov    0xc(%ebp),%edx
80101e43:	66 89 42 0c          	mov    %ax,0xc(%edx)
  st->size = ip->size;
80101e47:	8b 45 08             	mov    0x8(%ebp),%eax
80101e4a:	8b 50 58             	mov    0x58(%eax),%edx
80101e4d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e50:	89 50 10             	mov    %edx,0x10(%eax)
}
80101e53:	5d                   	pop    %ebp
80101e54:	c3                   	ret    

80101e55 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101e55:	55                   	push   %ebp
80101e56:	89 e5                	mov    %esp,%ebp
80101e58:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101e5b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e5e:	8b 40 50             	mov    0x50(%eax),%eax
80101e61:	66 83 f8 03          	cmp    $0x3,%ax
80101e65:	75 60                	jne    80101ec7 <readi+0x72>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101e67:	8b 45 08             	mov    0x8(%ebp),%eax
80101e6a:	66 8b 40 52          	mov    0x52(%eax),%ax
80101e6e:	66 85 c0             	test   %ax,%ax
80101e71:	78 20                	js     80101e93 <readi+0x3e>
80101e73:	8b 45 08             	mov    0x8(%ebp),%eax
80101e76:	66 8b 40 52          	mov    0x52(%eax),%ax
80101e7a:	66 83 f8 09          	cmp    $0x9,%ax
80101e7e:	7f 13                	jg     80101e93 <readi+0x3e>
80101e80:	8b 45 08             	mov    0x8(%ebp),%eax
80101e83:	66 8b 40 52          	mov    0x52(%eax),%ax
80101e87:	98                   	cwtl   
80101e88:	8b 04 c5 80 1c 11 80 	mov    -0x7feee380(,%eax,8),%eax
80101e8f:	85 c0                	test   %eax,%eax
80101e91:	75 0a                	jne    80101e9d <readi+0x48>
      return -1;
80101e93:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101e98:	e9 1a 01 00 00       	jmp    80101fb7 <readi+0x162>
    return devsw[ip->major].read(ip, dst, n);
80101e9d:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea0:	66 8b 40 52          	mov    0x52(%eax),%ax
80101ea4:	98                   	cwtl   
80101ea5:	8b 04 c5 80 1c 11 80 	mov    -0x7feee380(,%eax,8),%eax
80101eac:	8b 55 14             	mov    0x14(%ebp),%edx
80101eaf:	89 54 24 08          	mov    %edx,0x8(%esp)
80101eb3:	8b 55 0c             	mov    0xc(%ebp),%edx
80101eb6:	89 54 24 04          	mov    %edx,0x4(%esp)
80101eba:	8b 55 08             	mov    0x8(%ebp),%edx
80101ebd:	89 14 24             	mov    %edx,(%esp)
80101ec0:	ff d0                	call   *%eax
80101ec2:	e9 f0 00 00 00       	jmp    80101fb7 <readi+0x162>
  }

  if(off > ip->size || off + n < off)
80101ec7:	8b 45 08             	mov    0x8(%ebp),%eax
80101eca:	8b 40 58             	mov    0x58(%eax),%eax
80101ecd:	3b 45 10             	cmp    0x10(%ebp),%eax
80101ed0:	72 0d                	jb     80101edf <readi+0x8a>
80101ed2:	8b 45 14             	mov    0x14(%ebp),%eax
80101ed5:	8b 55 10             	mov    0x10(%ebp),%edx
80101ed8:	01 d0                	add    %edx,%eax
80101eda:	3b 45 10             	cmp    0x10(%ebp),%eax
80101edd:	73 0a                	jae    80101ee9 <readi+0x94>
    return -1;
80101edf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101ee4:	e9 ce 00 00 00       	jmp    80101fb7 <readi+0x162>
  if(off + n > ip->size)
80101ee9:	8b 45 14             	mov    0x14(%ebp),%eax
80101eec:	8b 55 10             	mov    0x10(%ebp),%edx
80101eef:	01 c2                	add    %eax,%edx
80101ef1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef4:	8b 40 58             	mov    0x58(%eax),%eax
80101ef7:	39 c2                	cmp    %eax,%edx
80101ef9:	76 0c                	jbe    80101f07 <readi+0xb2>
    n = ip->size - off;
80101efb:	8b 45 08             	mov    0x8(%ebp),%eax
80101efe:	8b 40 58             	mov    0x58(%eax),%eax
80101f01:	2b 45 10             	sub    0x10(%ebp),%eax
80101f04:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f07:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f0e:	e9 95 00 00 00       	jmp    80101fa8 <readi+0x153>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f13:	8b 45 10             	mov    0x10(%ebp),%eax
80101f16:	c1 e8 09             	shr    $0x9,%eax
80101f19:	89 44 24 04          	mov    %eax,0x4(%esp)
80101f1d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f20:	89 04 24             	mov    %eax,(%esp)
80101f23:	e8 b3 fc ff ff       	call   80101bdb <bmap>
80101f28:	8b 55 08             	mov    0x8(%ebp),%edx
80101f2b:	8b 12                	mov    (%edx),%edx
80101f2d:	89 44 24 04          	mov    %eax,0x4(%esp)
80101f31:	89 14 24             	mov    %edx,(%esp)
80101f34:	e8 7c e2 ff ff       	call   801001b5 <bread>
80101f39:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101f3c:	8b 45 10             	mov    0x10(%ebp),%eax
80101f3f:	25 ff 01 00 00       	and    $0x1ff,%eax
80101f44:	89 c2                	mov    %eax,%edx
80101f46:	b8 00 02 00 00       	mov    $0x200,%eax
80101f4b:	29 d0                	sub    %edx,%eax
80101f4d:	89 c1                	mov    %eax,%ecx
80101f4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f52:	8b 55 14             	mov    0x14(%ebp),%edx
80101f55:	29 c2                	sub    %eax,%edx
80101f57:	89 c8                	mov    %ecx,%eax
80101f59:	39 d0                	cmp    %edx,%eax
80101f5b:	76 02                	jbe    80101f5f <readi+0x10a>
80101f5d:	89 d0                	mov    %edx,%eax
80101f5f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101f62:	8b 45 10             	mov    0x10(%ebp),%eax
80101f65:	25 ff 01 00 00       	and    $0x1ff,%eax
80101f6a:	8d 50 50             	lea    0x50(%eax),%edx
80101f6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f70:	01 d0                	add    %edx,%eax
80101f72:	8d 50 0c             	lea    0xc(%eax),%edx
80101f75:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f78:	89 44 24 08          	mov    %eax,0x8(%esp)
80101f7c:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f80:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f83:	89 04 24             	mov    %eax,(%esp)
80101f86:	e8 6c 31 00 00       	call   801050f7 <memmove>
    brelse(bp);
80101f8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f8e:	89 04 24             	mov    %eax,(%esp)
80101f91:	e8 96 e2 ff ff       	call   8010022c <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f96:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f99:	01 45 f4             	add    %eax,-0xc(%ebp)
80101f9c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f9f:	01 45 10             	add    %eax,0x10(%ebp)
80101fa2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101fa5:	01 45 0c             	add    %eax,0xc(%ebp)
80101fa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101fab:	3b 45 14             	cmp    0x14(%ebp),%eax
80101fae:	0f 82 5f ff ff ff    	jb     80101f13 <readi+0xbe>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80101fb4:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101fb7:	c9                   	leave  
80101fb8:	c3                   	ret    

80101fb9 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101fb9:	55                   	push   %ebp
80101fba:	89 e5                	mov    %esp,%ebp
80101fbc:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101fbf:	8b 45 08             	mov    0x8(%ebp),%eax
80101fc2:	8b 40 50             	mov    0x50(%eax),%eax
80101fc5:	66 83 f8 03          	cmp    $0x3,%ax
80101fc9:	75 60                	jne    8010202b <writei+0x72>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101fcb:	8b 45 08             	mov    0x8(%ebp),%eax
80101fce:	66 8b 40 52          	mov    0x52(%eax),%ax
80101fd2:	66 85 c0             	test   %ax,%ax
80101fd5:	78 20                	js     80101ff7 <writei+0x3e>
80101fd7:	8b 45 08             	mov    0x8(%ebp),%eax
80101fda:	66 8b 40 52          	mov    0x52(%eax),%ax
80101fde:	66 83 f8 09          	cmp    $0x9,%ax
80101fe2:	7f 13                	jg     80101ff7 <writei+0x3e>
80101fe4:	8b 45 08             	mov    0x8(%ebp),%eax
80101fe7:	66 8b 40 52          	mov    0x52(%eax),%ax
80101feb:	98                   	cwtl   
80101fec:	8b 04 c5 84 1c 11 80 	mov    -0x7feee37c(,%eax,8),%eax
80101ff3:	85 c0                	test   %eax,%eax
80101ff5:	75 0a                	jne    80102001 <writei+0x48>
      return -1;
80101ff7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101ffc:	e9 45 01 00 00       	jmp    80102146 <writei+0x18d>
    return devsw[ip->major].write(ip, src, n);
80102001:	8b 45 08             	mov    0x8(%ebp),%eax
80102004:	66 8b 40 52          	mov    0x52(%eax),%ax
80102008:	98                   	cwtl   
80102009:	8b 04 c5 84 1c 11 80 	mov    -0x7feee37c(,%eax,8),%eax
80102010:	8b 55 14             	mov    0x14(%ebp),%edx
80102013:	89 54 24 08          	mov    %edx,0x8(%esp)
80102017:	8b 55 0c             	mov    0xc(%ebp),%edx
8010201a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010201e:	8b 55 08             	mov    0x8(%ebp),%edx
80102021:	89 14 24             	mov    %edx,(%esp)
80102024:	ff d0                	call   *%eax
80102026:	e9 1b 01 00 00       	jmp    80102146 <writei+0x18d>
  }

  if(off > ip->size || off + n < off)
8010202b:	8b 45 08             	mov    0x8(%ebp),%eax
8010202e:	8b 40 58             	mov    0x58(%eax),%eax
80102031:	3b 45 10             	cmp    0x10(%ebp),%eax
80102034:	72 0d                	jb     80102043 <writei+0x8a>
80102036:	8b 45 14             	mov    0x14(%ebp),%eax
80102039:	8b 55 10             	mov    0x10(%ebp),%edx
8010203c:	01 d0                	add    %edx,%eax
8010203e:	3b 45 10             	cmp    0x10(%ebp),%eax
80102041:	73 0a                	jae    8010204d <writei+0x94>
    return -1;
80102043:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102048:	e9 f9 00 00 00       	jmp    80102146 <writei+0x18d>
  if(off + n > MAXFILE*BSIZE)
8010204d:	8b 45 14             	mov    0x14(%ebp),%eax
80102050:	8b 55 10             	mov    0x10(%ebp),%edx
80102053:	01 d0                	add    %edx,%eax
80102055:	3d 00 18 01 00       	cmp    $0x11800,%eax
8010205a:	76 0a                	jbe    80102066 <writei+0xad>
    return -1;
8010205c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102061:	e9 e0 00 00 00       	jmp    80102146 <writei+0x18d>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102066:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010206d:	e9 a0 00 00 00       	jmp    80102112 <writei+0x159>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102072:	8b 45 10             	mov    0x10(%ebp),%eax
80102075:	c1 e8 09             	shr    $0x9,%eax
80102078:	89 44 24 04          	mov    %eax,0x4(%esp)
8010207c:	8b 45 08             	mov    0x8(%ebp),%eax
8010207f:	89 04 24             	mov    %eax,(%esp)
80102082:	e8 54 fb ff ff       	call   80101bdb <bmap>
80102087:	8b 55 08             	mov    0x8(%ebp),%edx
8010208a:	8b 12                	mov    (%edx),%edx
8010208c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102090:	89 14 24             	mov    %edx,(%esp)
80102093:	e8 1d e1 ff ff       	call   801001b5 <bread>
80102098:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010209b:	8b 45 10             	mov    0x10(%ebp),%eax
8010209e:	25 ff 01 00 00       	and    $0x1ff,%eax
801020a3:	89 c2                	mov    %eax,%edx
801020a5:	b8 00 02 00 00       	mov    $0x200,%eax
801020aa:	29 d0                	sub    %edx,%eax
801020ac:	89 c1                	mov    %eax,%ecx
801020ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020b1:	8b 55 14             	mov    0x14(%ebp),%edx
801020b4:	29 c2                	sub    %eax,%edx
801020b6:	89 c8                	mov    %ecx,%eax
801020b8:	39 d0                	cmp    %edx,%eax
801020ba:	76 02                	jbe    801020be <writei+0x105>
801020bc:	89 d0                	mov    %edx,%eax
801020be:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801020c1:	8b 45 10             	mov    0x10(%ebp),%eax
801020c4:	25 ff 01 00 00       	and    $0x1ff,%eax
801020c9:	8d 50 50             	lea    0x50(%eax),%edx
801020cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801020cf:	01 d0                	add    %edx,%eax
801020d1:	8d 50 0c             	lea    0xc(%eax),%edx
801020d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020d7:	89 44 24 08          	mov    %eax,0x8(%esp)
801020db:	8b 45 0c             	mov    0xc(%ebp),%eax
801020de:	89 44 24 04          	mov    %eax,0x4(%esp)
801020e2:	89 14 24             	mov    %edx,(%esp)
801020e5:	e8 0d 30 00 00       	call   801050f7 <memmove>
    log_write(bp);
801020ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801020ed:	89 04 24             	mov    %eax,(%esp)
801020f0:	e8 c6 15 00 00       	call   801036bb <log_write>
    brelse(bp);
801020f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801020f8:	89 04 24             	mov    %eax,(%esp)
801020fb:	e8 2c e1 ff ff       	call   8010022c <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102100:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102103:	01 45 f4             	add    %eax,-0xc(%ebp)
80102106:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102109:	01 45 10             	add    %eax,0x10(%ebp)
8010210c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010210f:	01 45 0c             	add    %eax,0xc(%ebp)
80102112:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102115:	3b 45 14             	cmp    0x14(%ebp),%eax
80102118:	0f 82 54 ff ff ff    	jb     80102072 <writei+0xb9>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
8010211e:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102122:	74 1f                	je     80102143 <writei+0x18a>
80102124:	8b 45 08             	mov    0x8(%ebp),%eax
80102127:	8b 40 58             	mov    0x58(%eax),%eax
8010212a:	3b 45 10             	cmp    0x10(%ebp),%eax
8010212d:	73 14                	jae    80102143 <writei+0x18a>
    ip->size = off;
8010212f:	8b 45 08             	mov    0x8(%ebp),%eax
80102132:	8b 55 10             	mov    0x10(%ebp),%edx
80102135:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
80102138:	8b 45 08             	mov    0x8(%ebp),%eax
8010213b:	89 04 24             	mov    %eax,(%esp)
8010213e:	e8 b8 f6 ff ff       	call   801017fb <iupdate>
  }
  return n;
80102143:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102146:	c9                   	leave  
80102147:	c3                   	ret    

80102148 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102148:	55                   	push   %ebp
80102149:	89 e5                	mov    %esp,%ebp
8010214b:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
8010214e:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102155:	00 
80102156:	8b 45 0c             	mov    0xc(%ebp),%eax
80102159:	89 44 24 04          	mov    %eax,0x4(%esp)
8010215d:	8b 45 08             	mov    0x8(%ebp),%eax
80102160:	89 04 24             	mov    %eax,(%esp)
80102163:	e8 2e 30 00 00       	call   80105196 <strncmp>
}
80102168:	c9                   	leave  
80102169:	c3                   	ret    

8010216a <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
8010216a:	55                   	push   %ebp
8010216b:	89 e5                	mov    %esp,%ebp
8010216d:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102170:	8b 45 08             	mov    0x8(%ebp),%eax
80102173:	8b 40 50             	mov    0x50(%eax),%eax
80102176:	66 83 f8 01          	cmp    $0x1,%ax
8010217a:	74 0c                	je     80102188 <dirlookup+0x1e>
    panic("dirlookup not DIR");
8010217c:	c7 04 24 4d 89 10 80 	movl   $0x8010894d,(%esp)
80102183:	e8 cc e3 ff ff       	call   80100554 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
80102188:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010218f:	e9 86 00 00 00       	jmp    8010221a <dirlookup+0xb0>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102194:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010219b:	00 
8010219c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010219f:	89 44 24 08          	mov    %eax,0x8(%esp)
801021a3:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021a6:	89 44 24 04          	mov    %eax,0x4(%esp)
801021aa:	8b 45 08             	mov    0x8(%ebp),%eax
801021ad:	89 04 24             	mov    %eax,(%esp)
801021b0:	e8 a0 fc ff ff       	call   80101e55 <readi>
801021b5:	83 f8 10             	cmp    $0x10,%eax
801021b8:	74 0c                	je     801021c6 <dirlookup+0x5c>
      panic("dirlookup read");
801021ba:	c7 04 24 5f 89 10 80 	movl   $0x8010895f,(%esp)
801021c1:	e8 8e e3 ff ff       	call   80100554 <panic>
    if(de.inum == 0)
801021c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801021c9:	66 85 c0             	test   %ax,%ax
801021cc:	75 02                	jne    801021d0 <dirlookup+0x66>
      continue;
801021ce:	eb 46                	jmp    80102216 <dirlookup+0xac>
    if(namecmp(name, de.name) == 0){
801021d0:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021d3:	83 c0 02             	add    $0x2,%eax
801021d6:	89 44 24 04          	mov    %eax,0x4(%esp)
801021da:	8b 45 0c             	mov    0xc(%ebp),%eax
801021dd:	89 04 24             	mov    %eax,(%esp)
801021e0:	e8 63 ff ff ff       	call   80102148 <namecmp>
801021e5:	85 c0                	test   %eax,%eax
801021e7:	75 2d                	jne    80102216 <dirlookup+0xac>
      // entry matches path element
      if(poff)
801021e9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801021ed:	74 08                	je     801021f7 <dirlookup+0x8d>
        *poff = off;
801021ef:	8b 45 10             	mov    0x10(%ebp),%eax
801021f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801021f5:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
801021f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801021fa:	0f b7 c0             	movzwl %ax,%eax
801021fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102200:	8b 45 08             	mov    0x8(%ebp),%eax
80102203:	8b 00                	mov    (%eax),%eax
80102205:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102208:	89 54 24 04          	mov    %edx,0x4(%esp)
8010220c:	89 04 24             	mov    %eax,(%esp)
8010220f:	e8 a3 f6 ff ff       	call   801018b7 <iget>
80102214:	eb 18                	jmp    8010222e <dirlookup+0xc4>
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102216:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010221a:	8b 45 08             	mov    0x8(%ebp),%eax
8010221d:	8b 40 58             	mov    0x58(%eax),%eax
80102220:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102223:	0f 87 6b ff ff ff    	ja     80102194 <dirlookup+0x2a>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
80102229:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010222e:	c9                   	leave  
8010222f:	c3                   	ret    

80102230 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102230:	55                   	push   %ebp
80102231:	89 e5                	mov    %esp,%ebp
80102233:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102236:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010223d:	00 
8010223e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102241:	89 44 24 04          	mov    %eax,0x4(%esp)
80102245:	8b 45 08             	mov    0x8(%ebp),%eax
80102248:	89 04 24             	mov    %eax,(%esp)
8010224b:	e8 1a ff ff ff       	call   8010216a <dirlookup>
80102250:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102253:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102257:	74 15                	je     8010226e <dirlink+0x3e>
    iput(ip);
80102259:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010225c:	89 04 24             	mov    %eax,(%esp)
8010225f:	e8 a8 f8 ff ff       	call   80101b0c <iput>
    return -1;
80102264:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102269:	e9 b6 00 00 00       	jmp    80102324 <dirlink+0xf4>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
8010226e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102275:	eb 45                	jmp    801022bc <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102277:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010227a:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102281:	00 
80102282:	89 44 24 08          	mov    %eax,0x8(%esp)
80102286:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102289:	89 44 24 04          	mov    %eax,0x4(%esp)
8010228d:	8b 45 08             	mov    0x8(%ebp),%eax
80102290:	89 04 24             	mov    %eax,(%esp)
80102293:	e8 bd fb ff ff       	call   80101e55 <readi>
80102298:	83 f8 10             	cmp    $0x10,%eax
8010229b:	74 0c                	je     801022a9 <dirlink+0x79>
      panic("dirlink read");
8010229d:	c7 04 24 6e 89 10 80 	movl   $0x8010896e,(%esp)
801022a4:	e8 ab e2 ff ff       	call   80100554 <panic>
    if(de.inum == 0)
801022a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801022ac:	66 85 c0             	test   %ax,%ax
801022af:	75 02                	jne    801022b3 <dirlink+0x83>
      break;
801022b1:	eb 16                	jmp    801022c9 <dirlink+0x99>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022b6:	83 c0 10             	add    $0x10,%eax
801022b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801022bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801022bf:	8b 45 08             	mov    0x8(%ebp),%eax
801022c2:	8b 40 58             	mov    0x58(%eax),%eax
801022c5:	39 c2                	cmp    %eax,%edx
801022c7:	72 ae                	jb     80102277 <dirlink+0x47>
      panic("dirlink read");
    if(de.inum == 0)
      break;
  }

  strncpy(de.name, name, DIRSIZ);
801022c9:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801022d0:	00 
801022d1:	8b 45 0c             	mov    0xc(%ebp),%eax
801022d4:	89 44 24 04          	mov    %eax,0x4(%esp)
801022d8:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022db:	83 c0 02             	add    $0x2,%eax
801022de:	89 04 24             	mov    %eax,(%esp)
801022e1:	e8 fe 2e 00 00       	call   801051e4 <strncpy>
  de.inum = inum;
801022e6:	8b 45 10             	mov    0x10(%ebp),%eax
801022e9:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022f0:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801022f7:	00 
801022f8:	89 44 24 08          	mov    %eax,0x8(%esp)
801022fc:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022ff:	89 44 24 04          	mov    %eax,0x4(%esp)
80102303:	8b 45 08             	mov    0x8(%ebp),%eax
80102306:	89 04 24             	mov    %eax,(%esp)
80102309:	e8 ab fc ff ff       	call   80101fb9 <writei>
8010230e:	83 f8 10             	cmp    $0x10,%eax
80102311:	74 0c                	je     8010231f <dirlink+0xef>
    panic("dirlink");
80102313:	c7 04 24 7b 89 10 80 	movl   $0x8010897b,(%esp)
8010231a:	e8 35 e2 ff ff       	call   80100554 <panic>

  return 0;
8010231f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102324:	c9                   	leave  
80102325:	c3                   	ret    

80102326 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102326:	55                   	push   %ebp
80102327:	89 e5                	mov    %esp,%ebp
80102329:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
8010232c:	eb 03                	jmp    80102331 <skipelem+0xb>
    path++;
8010232e:	ff 45 08             	incl   0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102331:	8b 45 08             	mov    0x8(%ebp),%eax
80102334:	8a 00                	mov    (%eax),%al
80102336:	3c 2f                	cmp    $0x2f,%al
80102338:	74 f4                	je     8010232e <skipelem+0x8>
    path++;
  if(*path == 0)
8010233a:	8b 45 08             	mov    0x8(%ebp),%eax
8010233d:	8a 00                	mov    (%eax),%al
8010233f:	84 c0                	test   %al,%al
80102341:	75 0a                	jne    8010234d <skipelem+0x27>
    return 0;
80102343:	b8 00 00 00 00       	mov    $0x0,%eax
80102348:	e9 81 00 00 00       	jmp    801023ce <skipelem+0xa8>
  s = path;
8010234d:	8b 45 08             	mov    0x8(%ebp),%eax
80102350:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102353:	eb 03                	jmp    80102358 <skipelem+0x32>
    path++;
80102355:	ff 45 08             	incl   0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80102358:	8b 45 08             	mov    0x8(%ebp),%eax
8010235b:	8a 00                	mov    (%eax),%al
8010235d:	3c 2f                	cmp    $0x2f,%al
8010235f:	74 09                	je     8010236a <skipelem+0x44>
80102361:	8b 45 08             	mov    0x8(%ebp),%eax
80102364:	8a 00                	mov    (%eax),%al
80102366:	84 c0                	test   %al,%al
80102368:	75 eb                	jne    80102355 <skipelem+0x2f>
    path++;
  len = path - s;
8010236a:	8b 55 08             	mov    0x8(%ebp),%edx
8010236d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102370:	29 c2                	sub    %eax,%edx
80102372:	89 d0                	mov    %edx,%eax
80102374:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102377:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
8010237b:	7e 1c                	jle    80102399 <skipelem+0x73>
    memmove(name, s, DIRSIZ);
8010237d:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102384:	00 
80102385:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102388:	89 44 24 04          	mov    %eax,0x4(%esp)
8010238c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010238f:	89 04 24             	mov    %eax,(%esp)
80102392:	e8 60 2d 00 00       	call   801050f7 <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102397:	eb 29                	jmp    801023c2 <skipelem+0x9c>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
80102399:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010239c:	89 44 24 08          	mov    %eax,0x8(%esp)
801023a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023a3:	89 44 24 04          	mov    %eax,0x4(%esp)
801023a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801023aa:	89 04 24             	mov    %eax,(%esp)
801023ad:	e8 45 2d 00 00       	call   801050f7 <memmove>
    name[len] = 0;
801023b2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801023b5:	8b 45 0c             	mov    0xc(%ebp),%eax
801023b8:	01 d0                	add    %edx,%eax
801023ba:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801023bd:	eb 03                	jmp    801023c2 <skipelem+0x9c>
    path++;
801023bf:	ff 45 08             	incl   0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801023c2:	8b 45 08             	mov    0x8(%ebp),%eax
801023c5:	8a 00                	mov    (%eax),%al
801023c7:	3c 2f                	cmp    $0x2f,%al
801023c9:	74 f4                	je     801023bf <skipelem+0x99>
    path++;
  return path;
801023cb:	8b 45 08             	mov    0x8(%ebp),%eax
}
801023ce:	c9                   	leave  
801023cf:	c3                   	ret    

801023d0 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801023d0:	55                   	push   %ebp
801023d1:	89 e5                	mov    %esp,%ebp
801023d3:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
801023d6:	8b 45 08             	mov    0x8(%ebp),%eax
801023d9:	8a 00                	mov    (%eax),%al
801023db:	3c 2f                	cmp    $0x2f,%al
801023dd:	75 1c                	jne    801023fb <namex+0x2b>
    ip = iget(ROOTDEV, ROOTINO);
801023df:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801023e6:	00 
801023e7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801023ee:	e8 c4 f4 ff ff       	call   801018b7 <iget>
801023f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(myproc()->cwd);

  while((path = skipelem(path, name)) != 0){
801023f6:	e9 ac 00 00 00       	jmp    801024a7 <namex+0xd7>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
801023fb:	e8 af 1d 00 00       	call   801041af <myproc>
80102400:	8b 40 68             	mov    0x68(%eax),%eax
80102403:	89 04 24             	mov    %eax,(%esp)
80102406:	e8 81 f5 ff ff       	call   8010198c <idup>
8010240b:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010240e:	e9 94 00 00 00       	jmp    801024a7 <namex+0xd7>
    ilock(ip);
80102413:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102416:	89 04 24             	mov    %eax,(%esp)
80102419:	e8 a0 f5 ff ff       	call   801019be <ilock>
    if(ip->type != T_DIR){
8010241e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102421:	8b 40 50             	mov    0x50(%eax),%eax
80102424:	66 83 f8 01          	cmp    $0x1,%ax
80102428:	74 15                	je     8010243f <namex+0x6f>
      iunlockput(ip);
8010242a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010242d:	89 04 24             	mov    %eax,(%esp)
80102430:	e8 88 f7 ff ff       	call   80101bbd <iunlockput>
      return 0;
80102435:	b8 00 00 00 00       	mov    $0x0,%eax
8010243a:	e9 a2 00 00 00       	jmp    801024e1 <namex+0x111>
    }
    if(nameiparent && *path == '\0'){
8010243f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102443:	74 1c                	je     80102461 <namex+0x91>
80102445:	8b 45 08             	mov    0x8(%ebp),%eax
80102448:	8a 00                	mov    (%eax),%al
8010244a:	84 c0                	test   %al,%al
8010244c:	75 13                	jne    80102461 <namex+0x91>
      // Stop one level early.
      iunlock(ip);
8010244e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102451:	89 04 24             	mov    %eax,(%esp)
80102454:	e8 6f f6 ff ff       	call   80101ac8 <iunlock>
      return ip;
80102459:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010245c:	e9 80 00 00 00       	jmp    801024e1 <namex+0x111>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102461:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80102468:	00 
80102469:	8b 45 10             	mov    0x10(%ebp),%eax
8010246c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102470:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102473:	89 04 24             	mov    %eax,(%esp)
80102476:	e8 ef fc ff ff       	call   8010216a <dirlookup>
8010247b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010247e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102482:	75 12                	jne    80102496 <namex+0xc6>
      iunlockput(ip);
80102484:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102487:	89 04 24             	mov    %eax,(%esp)
8010248a:	e8 2e f7 ff ff       	call   80101bbd <iunlockput>
      return 0;
8010248f:	b8 00 00 00 00       	mov    $0x0,%eax
80102494:	eb 4b                	jmp    801024e1 <namex+0x111>
    }
    iunlockput(ip);
80102496:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102499:	89 04 24             	mov    %eax,(%esp)
8010249c:	e8 1c f7 ff ff       	call   80101bbd <iunlockput>
    ip = next;
801024a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);

  while((path = skipelem(path, name)) != 0){
801024a7:	8b 45 10             	mov    0x10(%ebp),%eax
801024aa:	89 44 24 04          	mov    %eax,0x4(%esp)
801024ae:	8b 45 08             	mov    0x8(%ebp),%eax
801024b1:	89 04 24             	mov    %eax,(%esp)
801024b4:	e8 6d fe ff ff       	call   80102326 <skipelem>
801024b9:	89 45 08             	mov    %eax,0x8(%ebp)
801024bc:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801024c0:	0f 85 4d ff ff ff    	jne    80102413 <namex+0x43>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
801024c6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801024ca:	74 12                	je     801024de <namex+0x10e>
    iput(ip);
801024cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024cf:	89 04 24             	mov    %eax,(%esp)
801024d2:	e8 35 f6 ff ff       	call   80101b0c <iput>
    return 0;
801024d7:	b8 00 00 00 00       	mov    $0x0,%eax
801024dc:	eb 03                	jmp    801024e1 <namex+0x111>
  }
  return ip;
801024de:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801024e1:	c9                   	leave  
801024e2:	c3                   	ret    

801024e3 <namei>:

struct inode*
namei(char *path)
{
801024e3:	55                   	push   %ebp
801024e4:	89 e5                	mov    %esp,%ebp
801024e6:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
801024e9:	8d 45 ea             	lea    -0x16(%ebp),%eax
801024ec:	89 44 24 08          	mov    %eax,0x8(%esp)
801024f0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801024f7:	00 
801024f8:	8b 45 08             	mov    0x8(%ebp),%eax
801024fb:	89 04 24             	mov    %eax,(%esp)
801024fe:	e8 cd fe ff ff       	call   801023d0 <namex>
}
80102503:	c9                   	leave  
80102504:	c3                   	ret    

80102505 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102505:	55                   	push   %ebp
80102506:	89 e5                	mov    %esp,%ebp
80102508:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
8010250b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010250e:	89 44 24 08          	mov    %eax,0x8(%esp)
80102512:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102519:	00 
8010251a:	8b 45 08             	mov    0x8(%ebp),%eax
8010251d:	89 04 24             	mov    %eax,(%esp)
80102520:	e8 ab fe ff ff       	call   801023d0 <namex>
}
80102525:	c9                   	leave  
80102526:	c3                   	ret    
	...

80102528 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102528:	55                   	push   %ebp
80102529:	89 e5                	mov    %esp,%ebp
8010252b:	83 ec 14             	sub    $0x14,%esp
8010252e:	8b 45 08             	mov    0x8(%ebp),%eax
80102531:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102535:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102538:	89 c2                	mov    %eax,%edx
8010253a:	ec                   	in     (%dx),%al
8010253b:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010253e:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80102541:	c9                   	leave  
80102542:	c3                   	ret    

80102543 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102543:	55                   	push   %ebp
80102544:	89 e5                	mov    %esp,%ebp
80102546:	57                   	push   %edi
80102547:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102548:	8b 55 08             	mov    0x8(%ebp),%edx
8010254b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010254e:	8b 45 10             	mov    0x10(%ebp),%eax
80102551:	89 cb                	mov    %ecx,%ebx
80102553:	89 df                	mov    %ebx,%edi
80102555:	89 c1                	mov    %eax,%ecx
80102557:	fc                   	cld    
80102558:	f3 6d                	rep insl (%dx),%es:(%edi)
8010255a:	89 c8                	mov    %ecx,%eax
8010255c:	89 fb                	mov    %edi,%ebx
8010255e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102561:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102564:	5b                   	pop    %ebx
80102565:	5f                   	pop    %edi
80102566:	5d                   	pop    %ebp
80102567:	c3                   	ret    

80102568 <outb>:

static inline void
outb(ushort port, uchar data)
{
80102568:	55                   	push   %ebp
80102569:	89 e5                	mov    %esp,%ebp
8010256b:	83 ec 08             	sub    $0x8,%esp
8010256e:	8b 45 08             	mov    0x8(%ebp),%eax
80102571:	8b 55 0c             	mov    0xc(%ebp),%edx
80102574:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102578:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010257b:	8a 45 f8             	mov    -0x8(%ebp),%al
8010257e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80102581:	ee                   	out    %al,(%dx)
}
80102582:	c9                   	leave  
80102583:	c3                   	ret    

80102584 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102584:	55                   	push   %ebp
80102585:	89 e5                	mov    %esp,%ebp
80102587:	56                   	push   %esi
80102588:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102589:	8b 55 08             	mov    0x8(%ebp),%edx
8010258c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010258f:	8b 45 10             	mov    0x10(%ebp),%eax
80102592:	89 cb                	mov    %ecx,%ebx
80102594:	89 de                	mov    %ebx,%esi
80102596:	89 c1                	mov    %eax,%ecx
80102598:	fc                   	cld    
80102599:	f3 6f                	rep outsl %ds:(%esi),(%dx)
8010259b:	89 c8                	mov    %ecx,%eax
8010259d:	89 f3                	mov    %esi,%ebx
8010259f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801025a2:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
801025a5:	5b                   	pop    %ebx
801025a6:	5e                   	pop    %esi
801025a7:	5d                   	pop    %ebp
801025a8:	c3                   	ret    

801025a9 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801025a9:	55                   	push   %ebp
801025aa:	89 e5                	mov    %esp,%ebp
801025ac:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801025af:	90                   	nop
801025b0:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801025b7:	e8 6c ff ff ff       	call   80102528 <inb>
801025bc:	0f b6 c0             	movzbl %al,%eax
801025bf:	89 45 fc             	mov    %eax,-0x4(%ebp)
801025c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801025c5:	25 c0 00 00 00       	and    $0xc0,%eax
801025ca:	83 f8 40             	cmp    $0x40,%eax
801025cd:	75 e1                	jne    801025b0 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801025cf:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801025d3:	74 11                	je     801025e6 <idewait+0x3d>
801025d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801025d8:	83 e0 21             	and    $0x21,%eax
801025db:	85 c0                	test   %eax,%eax
801025dd:	74 07                	je     801025e6 <idewait+0x3d>
    return -1;
801025df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801025e4:	eb 05                	jmp    801025eb <idewait+0x42>
  return 0;
801025e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801025eb:	c9                   	leave  
801025ec:	c3                   	ret    

801025ed <ideinit>:

void
ideinit(void)
{
801025ed:	55                   	push   %ebp
801025ee:	89 e5                	mov    %esp,%ebp
801025f0:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
801025f3:	c7 44 24 04 83 89 10 	movl   $0x80108983,0x4(%esp)
801025fa:	80 
801025fb:	c7 04 24 80 b8 10 80 	movl   $0x8010b880,(%esp)
80102602:	e8 a3 27 00 00       	call   80104daa <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102607:	a1 20 40 11 80       	mov    0x80114020,%eax
8010260c:	48                   	dec    %eax
8010260d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102611:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102618:	e8 66 04 00 00       	call   80102a83 <ioapicenable>
  idewait(0);
8010261d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102624:	e8 80 ff ff ff       	call   801025a9 <idewait>

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102629:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
80102630:	00 
80102631:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102638:	e8 2b ff ff ff       	call   80102568 <outb>
  for(i=0; i<1000; i++){
8010263d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102644:	eb 1f                	jmp    80102665 <ideinit+0x78>
    if(inb(0x1f7) != 0){
80102646:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
8010264d:	e8 d6 fe ff ff       	call   80102528 <inb>
80102652:	84 c0                	test   %al,%al
80102654:	74 0c                	je     80102662 <ideinit+0x75>
      havedisk1 = 1;
80102656:	c7 05 b8 b8 10 80 01 	movl   $0x1,0x8010b8b8
8010265d:	00 00 00 
      break;
80102660:	eb 0c                	jmp    8010266e <ideinit+0x81>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102662:	ff 45 f4             	incl   -0xc(%ebp)
80102665:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
8010266c:	7e d8                	jle    80102646 <ideinit+0x59>
      break;
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
8010266e:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
80102675:	00 
80102676:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
8010267d:	e8 e6 fe ff ff       	call   80102568 <outb>
}
80102682:	c9                   	leave  
80102683:	c3                   	ret    

80102684 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102684:	55                   	push   %ebp
80102685:	89 e5                	mov    %esp,%ebp
80102687:	83 ec 28             	sub    $0x28,%esp
  if(b == 0)
8010268a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010268e:	75 0c                	jne    8010269c <idestart+0x18>
    panic("idestart");
80102690:	c7 04 24 87 89 10 80 	movl   $0x80108987,(%esp)
80102697:	e8 b8 de ff ff       	call   80100554 <panic>
  if(b->blockno >= FSSIZE)
8010269c:	8b 45 08             	mov    0x8(%ebp),%eax
8010269f:	8b 40 08             	mov    0x8(%eax),%eax
801026a2:	3d e7 03 00 00       	cmp    $0x3e7,%eax
801026a7:	76 0c                	jbe    801026b5 <idestart+0x31>
    panic("incorrect blockno");
801026a9:	c7 04 24 90 89 10 80 	movl   $0x80108990,(%esp)
801026b0:	e8 9f de ff ff       	call   80100554 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
801026b5:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
801026bc:	8b 45 08             	mov    0x8(%ebp),%eax
801026bf:	8b 50 08             	mov    0x8(%eax),%edx
801026c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026c5:	0f af c2             	imul   %edx,%eax
801026c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
801026cb:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801026cf:	75 07                	jne    801026d8 <idestart+0x54>
801026d1:	b8 20 00 00 00       	mov    $0x20,%eax
801026d6:	eb 05                	jmp    801026dd <idestart+0x59>
801026d8:	b8 c4 00 00 00       	mov    $0xc4,%eax
801026dd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
801026e0:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801026e4:	75 07                	jne    801026ed <idestart+0x69>
801026e6:	b8 30 00 00 00       	mov    $0x30,%eax
801026eb:	eb 05                	jmp    801026f2 <idestart+0x6e>
801026ed:	b8 c5 00 00 00       	mov    $0xc5,%eax
801026f2:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
801026f5:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
801026f9:	7e 0c                	jle    80102707 <idestart+0x83>
801026fb:	c7 04 24 87 89 10 80 	movl   $0x80108987,(%esp)
80102702:	e8 4d de ff ff       	call   80100554 <panic>

  idewait(0);
80102707:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010270e:	e8 96 fe ff ff       	call   801025a9 <idewait>
  outb(0x3f6, 0);  // generate interrupt
80102713:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010271a:	00 
8010271b:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
80102722:	e8 41 fe ff ff       	call   80102568 <outb>
  outb(0x1f2, sector_per_block);  // number of sectors
80102727:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010272a:	0f b6 c0             	movzbl %al,%eax
8010272d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102731:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
80102738:	e8 2b fe ff ff       	call   80102568 <outb>
  outb(0x1f3, sector & 0xff);
8010273d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102740:	0f b6 c0             	movzbl %al,%eax
80102743:	89 44 24 04          	mov    %eax,0x4(%esp)
80102747:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
8010274e:	e8 15 fe ff ff       	call   80102568 <outb>
  outb(0x1f4, (sector >> 8) & 0xff);
80102753:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102756:	c1 f8 08             	sar    $0x8,%eax
80102759:	0f b6 c0             	movzbl %al,%eax
8010275c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102760:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
80102767:	e8 fc fd ff ff       	call   80102568 <outb>
  outb(0x1f5, (sector >> 16) & 0xff);
8010276c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010276f:	c1 f8 10             	sar    $0x10,%eax
80102772:	0f b6 c0             	movzbl %al,%eax
80102775:	89 44 24 04          	mov    %eax,0x4(%esp)
80102779:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
80102780:	e8 e3 fd ff ff       	call   80102568 <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80102785:	8b 45 08             	mov    0x8(%ebp),%eax
80102788:	8b 40 04             	mov    0x4(%eax),%eax
8010278b:	83 e0 01             	and    $0x1,%eax
8010278e:	c1 e0 04             	shl    $0x4,%eax
80102791:	88 c2                	mov    %al,%dl
80102793:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102796:	c1 f8 18             	sar    $0x18,%eax
80102799:	83 e0 0f             	and    $0xf,%eax
8010279c:	09 d0                	or     %edx,%eax
8010279e:	83 c8 e0             	or     $0xffffffe0,%eax
801027a1:	0f b6 c0             	movzbl %al,%eax
801027a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801027a8:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801027af:	e8 b4 fd ff ff       	call   80102568 <outb>
  if(b->flags & B_DIRTY){
801027b4:	8b 45 08             	mov    0x8(%ebp),%eax
801027b7:	8b 00                	mov    (%eax),%eax
801027b9:	83 e0 04             	and    $0x4,%eax
801027bc:	85 c0                	test   %eax,%eax
801027be:	74 36                	je     801027f6 <idestart+0x172>
    outb(0x1f7, write_cmd);
801027c0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801027c3:	0f b6 c0             	movzbl %al,%eax
801027c6:	89 44 24 04          	mov    %eax,0x4(%esp)
801027ca:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801027d1:	e8 92 fd ff ff       	call   80102568 <outb>
    outsl(0x1f0, b->data, BSIZE/4);
801027d6:	8b 45 08             	mov    0x8(%ebp),%eax
801027d9:	83 c0 5c             	add    $0x5c,%eax
801027dc:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801027e3:	00 
801027e4:	89 44 24 04          	mov    %eax,0x4(%esp)
801027e8:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
801027ef:	e8 90 fd ff ff       	call   80102584 <outsl>
801027f4:	eb 16                	jmp    8010280c <idestart+0x188>
  } else {
    outb(0x1f7, read_cmd);
801027f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801027f9:	0f b6 c0             	movzbl %al,%eax
801027fc:	89 44 24 04          	mov    %eax,0x4(%esp)
80102800:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102807:	e8 5c fd ff ff       	call   80102568 <outb>
  }
}
8010280c:	c9                   	leave  
8010280d:	c3                   	ret    

8010280e <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010280e:	55                   	push   %ebp
8010280f:	89 e5                	mov    %esp,%ebp
80102811:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102814:	c7 04 24 80 b8 10 80 	movl   $0x8010b880,(%esp)
8010281b:	e8 ab 25 00 00       	call   80104dcb <acquire>

  if((b = idequeue) == 0){
80102820:	a1 b4 b8 10 80       	mov    0x8010b8b4,%eax
80102825:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102828:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010282c:	75 11                	jne    8010283f <ideintr+0x31>
    release(&idelock);
8010282e:	c7 04 24 80 b8 10 80 	movl   $0x8010b880,(%esp)
80102835:	e8 fb 25 00 00       	call   80104e35 <release>
    return;
8010283a:	e9 90 00 00 00       	jmp    801028cf <ideintr+0xc1>
  }
  idequeue = b->qnext;
8010283f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102842:	8b 40 58             	mov    0x58(%eax),%eax
80102845:	a3 b4 b8 10 80       	mov    %eax,0x8010b8b4

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
8010284a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010284d:	8b 00                	mov    (%eax),%eax
8010284f:	83 e0 04             	and    $0x4,%eax
80102852:	85 c0                	test   %eax,%eax
80102854:	75 2e                	jne    80102884 <ideintr+0x76>
80102856:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010285d:	e8 47 fd ff ff       	call   801025a9 <idewait>
80102862:	85 c0                	test   %eax,%eax
80102864:	78 1e                	js     80102884 <ideintr+0x76>
    insl(0x1f0, b->data, BSIZE/4);
80102866:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102869:	83 c0 5c             	add    $0x5c,%eax
8010286c:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102873:	00 
80102874:	89 44 24 04          	mov    %eax,0x4(%esp)
80102878:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
8010287f:	e8 bf fc ff ff       	call   80102543 <insl>

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102884:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102887:	8b 00                	mov    (%eax),%eax
80102889:	83 c8 02             	or     $0x2,%eax
8010288c:	89 c2                	mov    %eax,%edx
8010288e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102891:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102893:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102896:	8b 00                	mov    (%eax),%eax
80102898:	83 e0 fb             	and    $0xfffffffb,%eax
8010289b:	89 c2                	mov    %eax,%edx
8010289d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028a0:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801028a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028a5:	89 04 24             	mov    %eax,(%esp)
801028a8:	e8 24 22 00 00       	call   80104ad1 <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
801028ad:	a1 b4 b8 10 80       	mov    0x8010b8b4,%eax
801028b2:	85 c0                	test   %eax,%eax
801028b4:	74 0d                	je     801028c3 <ideintr+0xb5>
    idestart(idequeue);
801028b6:	a1 b4 b8 10 80       	mov    0x8010b8b4,%eax
801028bb:	89 04 24             	mov    %eax,(%esp)
801028be:	e8 c1 fd ff ff       	call   80102684 <idestart>

  release(&idelock);
801028c3:	c7 04 24 80 b8 10 80 	movl   $0x8010b880,(%esp)
801028ca:	e8 66 25 00 00       	call   80104e35 <release>
}
801028cf:	c9                   	leave  
801028d0:	c3                   	ret    

801028d1 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
801028d1:	55                   	push   %ebp
801028d2:	89 e5                	mov    %esp,%ebp
801028d4:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!holdingsleep(&b->lock))
801028d7:	8b 45 08             	mov    0x8(%ebp),%eax
801028da:	83 c0 0c             	add    $0xc,%eax
801028dd:	89 04 24             	mov    %eax,(%esp)
801028e0:	e8 5e 24 00 00       	call   80104d43 <holdingsleep>
801028e5:	85 c0                	test   %eax,%eax
801028e7:	75 0c                	jne    801028f5 <iderw+0x24>
    panic("iderw: buf not locked");
801028e9:	c7 04 24 a2 89 10 80 	movl   $0x801089a2,(%esp)
801028f0:	e8 5f dc ff ff       	call   80100554 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801028f5:	8b 45 08             	mov    0x8(%ebp),%eax
801028f8:	8b 00                	mov    (%eax),%eax
801028fa:	83 e0 06             	and    $0x6,%eax
801028fd:	83 f8 02             	cmp    $0x2,%eax
80102900:	75 0c                	jne    8010290e <iderw+0x3d>
    panic("iderw: nothing to do");
80102902:	c7 04 24 b8 89 10 80 	movl   $0x801089b8,(%esp)
80102909:	e8 46 dc ff ff       	call   80100554 <panic>
  if(b->dev != 0 && !havedisk1)
8010290e:	8b 45 08             	mov    0x8(%ebp),%eax
80102911:	8b 40 04             	mov    0x4(%eax),%eax
80102914:	85 c0                	test   %eax,%eax
80102916:	74 15                	je     8010292d <iderw+0x5c>
80102918:	a1 b8 b8 10 80       	mov    0x8010b8b8,%eax
8010291d:	85 c0                	test   %eax,%eax
8010291f:	75 0c                	jne    8010292d <iderw+0x5c>
    panic("iderw: ide disk 1 not present");
80102921:	c7 04 24 cd 89 10 80 	movl   $0x801089cd,(%esp)
80102928:	e8 27 dc ff ff       	call   80100554 <panic>

  acquire(&idelock);  //DOC:acquire-lock
8010292d:	c7 04 24 80 b8 10 80 	movl   $0x8010b880,(%esp)
80102934:	e8 92 24 00 00       	call   80104dcb <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102939:	8b 45 08             	mov    0x8(%ebp),%eax
8010293c:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102943:	c7 45 f4 b4 b8 10 80 	movl   $0x8010b8b4,-0xc(%ebp)
8010294a:	eb 0b                	jmp    80102957 <iderw+0x86>
8010294c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010294f:	8b 00                	mov    (%eax),%eax
80102951:	83 c0 58             	add    $0x58,%eax
80102954:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102957:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010295a:	8b 00                	mov    (%eax),%eax
8010295c:	85 c0                	test   %eax,%eax
8010295e:	75 ec                	jne    8010294c <iderw+0x7b>
    ;
  *pp = b;
80102960:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102963:	8b 55 08             	mov    0x8(%ebp),%edx
80102966:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
80102968:	a1 b4 b8 10 80       	mov    0x8010b8b4,%eax
8010296d:	3b 45 08             	cmp    0x8(%ebp),%eax
80102970:	75 0d                	jne    8010297f <iderw+0xae>
    idestart(b);
80102972:	8b 45 08             	mov    0x8(%ebp),%eax
80102975:	89 04 24             	mov    %eax,(%esp)
80102978:	e8 07 fd ff ff       	call   80102684 <idestart>

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
8010297d:	eb 15                	jmp    80102994 <iderw+0xc3>
8010297f:	eb 13                	jmp    80102994 <iderw+0xc3>
    sleep(b, &idelock);
80102981:	c7 44 24 04 80 b8 10 	movl   $0x8010b880,0x4(%esp)
80102988:	80 
80102989:	8b 45 08             	mov    0x8(%ebp),%eax
8010298c:	89 04 24             	mov    %eax,(%esp)
8010298f:	e8 69 20 00 00       	call   801049fd <sleep>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102994:	8b 45 08             	mov    0x8(%ebp),%eax
80102997:	8b 00                	mov    (%eax),%eax
80102999:	83 e0 06             	and    $0x6,%eax
8010299c:	83 f8 02             	cmp    $0x2,%eax
8010299f:	75 e0                	jne    80102981 <iderw+0xb0>
    sleep(b, &idelock);
  }


  release(&idelock);
801029a1:	c7 04 24 80 b8 10 80 	movl   $0x8010b880,(%esp)
801029a8:	e8 88 24 00 00       	call   80104e35 <release>
}
801029ad:	c9                   	leave  
801029ae:	c3                   	ret    
	...

801029b0 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
801029b0:	55                   	push   %ebp
801029b1:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
801029b3:	a1 54 39 11 80       	mov    0x80113954,%eax
801029b8:	8b 55 08             	mov    0x8(%ebp),%edx
801029bb:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
801029bd:	a1 54 39 11 80       	mov    0x80113954,%eax
801029c2:	8b 40 10             	mov    0x10(%eax),%eax
}
801029c5:	5d                   	pop    %ebp
801029c6:	c3                   	ret    

801029c7 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
801029c7:	55                   	push   %ebp
801029c8:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
801029ca:	a1 54 39 11 80       	mov    0x80113954,%eax
801029cf:	8b 55 08             	mov    0x8(%ebp),%edx
801029d2:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
801029d4:	a1 54 39 11 80       	mov    0x80113954,%eax
801029d9:	8b 55 0c             	mov    0xc(%ebp),%edx
801029dc:	89 50 10             	mov    %edx,0x10(%eax)
}
801029df:	5d                   	pop    %ebp
801029e0:	c3                   	ret    

801029e1 <ioapicinit>:

void
ioapicinit(void)
{
801029e1:	55                   	push   %ebp
801029e2:	89 e5                	mov    %esp,%ebp
801029e4:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
801029e7:	c7 05 54 39 11 80 00 	movl   $0xfec00000,0x80113954
801029ee:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
801029f1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801029f8:	e8 b3 ff ff ff       	call   801029b0 <ioapicread>
801029fd:	c1 e8 10             	shr    $0x10,%eax
80102a00:	25 ff 00 00 00       	and    $0xff,%eax
80102a05:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102a08:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102a0f:	e8 9c ff ff ff       	call   801029b0 <ioapicread>
80102a14:	c1 e8 18             	shr    $0x18,%eax
80102a17:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102a1a:	a0 80 3a 11 80       	mov    0x80113a80,%al
80102a1f:	0f b6 c0             	movzbl %al,%eax
80102a22:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102a25:	74 0c                	je     80102a33 <ioapicinit+0x52>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102a27:	c7 04 24 ec 89 10 80 	movl   $0x801089ec,(%esp)
80102a2e:	e8 8e d9 ff ff       	call   801003c1 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102a33:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102a3a:	eb 3d                	jmp    80102a79 <ioapicinit+0x98>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102a3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a3f:	83 c0 20             	add    $0x20,%eax
80102a42:	0d 00 00 01 00       	or     $0x10000,%eax
80102a47:	89 c2                	mov    %eax,%edx
80102a49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a4c:	83 c0 08             	add    $0x8,%eax
80102a4f:	01 c0                	add    %eax,%eax
80102a51:	89 54 24 04          	mov    %edx,0x4(%esp)
80102a55:	89 04 24             	mov    %eax,(%esp)
80102a58:	e8 6a ff ff ff       	call   801029c7 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102a5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a60:	83 c0 08             	add    $0x8,%eax
80102a63:	01 c0                	add    %eax,%eax
80102a65:	40                   	inc    %eax
80102a66:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102a6d:	00 
80102a6e:	89 04 24             	mov    %eax,(%esp)
80102a71:	e8 51 ff ff ff       	call   801029c7 <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102a76:	ff 45 f4             	incl   -0xc(%ebp)
80102a79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a7c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102a7f:	7e bb                	jle    80102a3c <ioapicinit+0x5b>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102a81:	c9                   	leave  
80102a82:	c3                   	ret    

80102a83 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102a83:	55                   	push   %ebp
80102a84:	89 e5                	mov    %esp,%ebp
80102a86:	83 ec 08             	sub    $0x8,%esp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102a89:	8b 45 08             	mov    0x8(%ebp),%eax
80102a8c:	83 c0 20             	add    $0x20,%eax
80102a8f:	89 c2                	mov    %eax,%edx
80102a91:	8b 45 08             	mov    0x8(%ebp),%eax
80102a94:	83 c0 08             	add    $0x8,%eax
80102a97:	01 c0                	add    %eax,%eax
80102a99:	89 54 24 04          	mov    %edx,0x4(%esp)
80102a9d:	89 04 24             	mov    %eax,(%esp)
80102aa0:	e8 22 ff ff ff       	call   801029c7 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102aa5:	8b 45 0c             	mov    0xc(%ebp),%eax
80102aa8:	c1 e0 18             	shl    $0x18,%eax
80102aab:	8b 55 08             	mov    0x8(%ebp),%edx
80102aae:	83 c2 08             	add    $0x8,%edx
80102ab1:	01 d2                	add    %edx,%edx
80102ab3:	42                   	inc    %edx
80102ab4:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ab8:	89 14 24             	mov    %edx,(%esp)
80102abb:	e8 07 ff ff ff       	call   801029c7 <ioapicwrite>
}
80102ac0:	c9                   	leave  
80102ac1:	c3                   	ret    
	...

80102ac4 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102ac4:	55                   	push   %ebp
80102ac5:	89 e5                	mov    %esp,%ebp
80102ac7:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
80102aca:	c7 44 24 04 1e 8a 10 	movl   $0x80108a1e,0x4(%esp)
80102ad1:	80 
80102ad2:	c7 04 24 60 39 11 80 	movl   $0x80113960,(%esp)
80102ad9:	e8 cc 22 00 00       	call   80104daa <initlock>
  kmem.use_lock = 0;
80102ade:	c7 05 94 39 11 80 00 	movl   $0x0,0x80113994
80102ae5:	00 00 00 
  freerange(vstart, vend);
80102ae8:	8b 45 0c             	mov    0xc(%ebp),%eax
80102aeb:	89 44 24 04          	mov    %eax,0x4(%esp)
80102aef:	8b 45 08             	mov    0x8(%ebp),%eax
80102af2:	89 04 24             	mov    %eax,(%esp)
80102af5:	e8 26 00 00 00       	call   80102b20 <freerange>
}
80102afa:	c9                   	leave  
80102afb:	c3                   	ret    

80102afc <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102afc:	55                   	push   %ebp
80102afd:	89 e5                	mov    %esp,%ebp
80102aff:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102b02:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b05:	89 44 24 04          	mov    %eax,0x4(%esp)
80102b09:	8b 45 08             	mov    0x8(%ebp),%eax
80102b0c:	89 04 24             	mov    %eax,(%esp)
80102b0f:	e8 0c 00 00 00       	call   80102b20 <freerange>
  kmem.use_lock = 1;
80102b14:	c7 05 94 39 11 80 01 	movl   $0x1,0x80113994
80102b1b:	00 00 00 
}
80102b1e:	c9                   	leave  
80102b1f:	c3                   	ret    

80102b20 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102b20:	55                   	push   %ebp
80102b21:	89 e5                	mov    %esp,%ebp
80102b23:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102b26:	8b 45 08             	mov    0x8(%ebp),%eax
80102b29:	05 ff 0f 00 00       	add    $0xfff,%eax
80102b2e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102b33:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102b36:	eb 12                	jmp    80102b4a <freerange+0x2a>
    kfree(p);
80102b38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b3b:	89 04 24             	mov    %eax,(%esp)
80102b3e:	e8 16 00 00 00       	call   80102b59 <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102b43:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102b4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b4d:	05 00 10 00 00       	add    $0x1000,%eax
80102b52:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102b55:	76 e1                	jbe    80102b38 <freerange+0x18>
    kfree(p);
}
80102b57:	c9                   	leave  
80102b58:	c3                   	ret    

80102b59 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102b59:	55                   	push   %ebp
80102b5a:	89 e5                	mov    %esp,%ebp
80102b5c:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102b5f:	8b 45 08             	mov    0x8(%ebp),%eax
80102b62:	25 ff 0f 00 00       	and    $0xfff,%eax
80102b67:	85 c0                	test   %eax,%eax
80102b69:	75 18                	jne    80102b83 <kfree+0x2a>
80102b6b:	81 7d 08 50 69 11 80 	cmpl   $0x80116950,0x8(%ebp)
80102b72:	72 0f                	jb     80102b83 <kfree+0x2a>
80102b74:	8b 45 08             	mov    0x8(%ebp),%eax
80102b77:	05 00 00 00 80       	add    $0x80000000,%eax
80102b7c:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102b81:	76 0c                	jbe    80102b8f <kfree+0x36>
    panic("kfree");
80102b83:	c7 04 24 23 8a 10 80 	movl   $0x80108a23,(%esp)
80102b8a:	e8 c5 d9 ff ff       	call   80100554 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102b8f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102b96:	00 
80102b97:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102b9e:	00 
80102b9f:	8b 45 08             	mov    0x8(%ebp),%eax
80102ba2:	89 04 24             	mov    %eax,(%esp)
80102ba5:	e8 84 24 00 00       	call   8010502e <memset>

  if(kmem.use_lock)
80102baa:	a1 94 39 11 80       	mov    0x80113994,%eax
80102baf:	85 c0                	test   %eax,%eax
80102bb1:	74 0c                	je     80102bbf <kfree+0x66>
    acquire(&kmem.lock);
80102bb3:	c7 04 24 60 39 11 80 	movl   $0x80113960,(%esp)
80102bba:	e8 0c 22 00 00       	call   80104dcb <acquire>
  r = (struct run*)v;
80102bbf:	8b 45 08             	mov    0x8(%ebp),%eax
80102bc2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102bc5:	8b 15 98 39 11 80    	mov    0x80113998,%edx
80102bcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bce:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102bd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bd3:	a3 98 39 11 80       	mov    %eax,0x80113998
  if(kmem.use_lock)
80102bd8:	a1 94 39 11 80       	mov    0x80113994,%eax
80102bdd:	85 c0                	test   %eax,%eax
80102bdf:	74 0c                	je     80102bed <kfree+0x94>
    release(&kmem.lock);
80102be1:	c7 04 24 60 39 11 80 	movl   $0x80113960,(%esp)
80102be8:	e8 48 22 00 00       	call   80104e35 <release>
}
80102bed:	c9                   	leave  
80102bee:	c3                   	ret    

80102bef <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102bef:	55                   	push   %ebp
80102bf0:	89 e5                	mov    %esp,%ebp
80102bf2:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102bf5:	a1 94 39 11 80       	mov    0x80113994,%eax
80102bfa:	85 c0                	test   %eax,%eax
80102bfc:	74 0c                	je     80102c0a <kalloc+0x1b>
    acquire(&kmem.lock);
80102bfe:	c7 04 24 60 39 11 80 	movl   $0x80113960,(%esp)
80102c05:	e8 c1 21 00 00       	call   80104dcb <acquire>
  r = kmem.freelist;
80102c0a:	a1 98 39 11 80       	mov    0x80113998,%eax
80102c0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102c12:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102c16:	74 0a                	je     80102c22 <kalloc+0x33>
    kmem.freelist = r->next;
80102c18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c1b:	8b 00                	mov    (%eax),%eax
80102c1d:	a3 98 39 11 80       	mov    %eax,0x80113998
  if(kmem.use_lock)
80102c22:	a1 94 39 11 80       	mov    0x80113994,%eax
80102c27:	85 c0                	test   %eax,%eax
80102c29:	74 0c                	je     80102c37 <kalloc+0x48>
    release(&kmem.lock);
80102c2b:	c7 04 24 60 39 11 80 	movl   $0x80113960,(%esp)
80102c32:	e8 fe 21 00 00       	call   80104e35 <release>
  return (char*)r;
80102c37:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102c3a:	c9                   	leave  
80102c3b:	c3                   	ret    

80102c3c <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102c3c:	55                   	push   %ebp
80102c3d:	89 e5                	mov    %esp,%ebp
80102c3f:	83 ec 14             	sub    $0x14,%esp
80102c42:	8b 45 08             	mov    0x8(%ebp),%eax
80102c45:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c49:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102c4c:	89 c2                	mov    %eax,%edx
80102c4e:	ec                   	in     (%dx),%al
80102c4f:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102c52:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80102c55:	c9                   	leave  
80102c56:	c3                   	ret    

80102c57 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102c57:	55                   	push   %ebp
80102c58:	89 e5                	mov    %esp,%ebp
80102c5a:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102c5d:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102c64:	e8 d3 ff ff ff       	call   80102c3c <inb>
80102c69:	0f b6 c0             	movzbl %al,%eax
80102c6c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102c6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c72:	83 e0 01             	and    $0x1,%eax
80102c75:	85 c0                	test   %eax,%eax
80102c77:	75 0a                	jne    80102c83 <kbdgetc+0x2c>
    return -1;
80102c79:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102c7e:	e9 21 01 00 00       	jmp    80102da4 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102c83:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102c8a:	e8 ad ff ff ff       	call   80102c3c <inb>
80102c8f:	0f b6 c0             	movzbl %al,%eax
80102c92:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102c95:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102c9c:	75 17                	jne    80102cb5 <kbdgetc+0x5e>
    shift |= E0ESC;
80102c9e:	a1 bc b8 10 80       	mov    0x8010b8bc,%eax
80102ca3:	83 c8 40             	or     $0x40,%eax
80102ca6:	a3 bc b8 10 80       	mov    %eax,0x8010b8bc
    return 0;
80102cab:	b8 00 00 00 00       	mov    $0x0,%eax
80102cb0:	e9 ef 00 00 00       	jmp    80102da4 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102cb5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102cb8:	25 80 00 00 00       	and    $0x80,%eax
80102cbd:	85 c0                	test   %eax,%eax
80102cbf:	74 44                	je     80102d05 <kbdgetc+0xae>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102cc1:	a1 bc b8 10 80       	mov    0x8010b8bc,%eax
80102cc6:	83 e0 40             	and    $0x40,%eax
80102cc9:	85 c0                	test   %eax,%eax
80102ccb:	75 08                	jne    80102cd5 <kbdgetc+0x7e>
80102ccd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102cd0:	83 e0 7f             	and    $0x7f,%eax
80102cd3:	eb 03                	jmp    80102cd8 <kbdgetc+0x81>
80102cd5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102cd8:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102cdb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102cde:	05 20 90 10 80       	add    $0x80109020,%eax
80102ce3:	8a 00                	mov    (%eax),%al
80102ce5:	83 c8 40             	or     $0x40,%eax
80102ce8:	0f b6 c0             	movzbl %al,%eax
80102ceb:	f7 d0                	not    %eax
80102ced:	89 c2                	mov    %eax,%edx
80102cef:	a1 bc b8 10 80       	mov    0x8010b8bc,%eax
80102cf4:	21 d0                	and    %edx,%eax
80102cf6:	a3 bc b8 10 80       	mov    %eax,0x8010b8bc
    return 0;
80102cfb:	b8 00 00 00 00       	mov    $0x0,%eax
80102d00:	e9 9f 00 00 00       	jmp    80102da4 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102d05:	a1 bc b8 10 80       	mov    0x8010b8bc,%eax
80102d0a:	83 e0 40             	and    $0x40,%eax
80102d0d:	85 c0                	test   %eax,%eax
80102d0f:	74 14                	je     80102d25 <kbdgetc+0xce>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102d11:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102d18:	a1 bc b8 10 80       	mov    0x8010b8bc,%eax
80102d1d:	83 e0 bf             	and    $0xffffffbf,%eax
80102d20:	a3 bc b8 10 80       	mov    %eax,0x8010b8bc
  }

  shift |= shiftcode[data];
80102d25:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d28:	05 20 90 10 80       	add    $0x80109020,%eax
80102d2d:	8a 00                	mov    (%eax),%al
80102d2f:	0f b6 d0             	movzbl %al,%edx
80102d32:	a1 bc b8 10 80       	mov    0x8010b8bc,%eax
80102d37:	09 d0                	or     %edx,%eax
80102d39:	a3 bc b8 10 80       	mov    %eax,0x8010b8bc
  shift ^= togglecode[data];
80102d3e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d41:	05 20 91 10 80       	add    $0x80109120,%eax
80102d46:	8a 00                	mov    (%eax),%al
80102d48:	0f b6 d0             	movzbl %al,%edx
80102d4b:	a1 bc b8 10 80       	mov    0x8010b8bc,%eax
80102d50:	31 d0                	xor    %edx,%eax
80102d52:	a3 bc b8 10 80       	mov    %eax,0x8010b8bc
  c = charcode[shift & (CTL | SHIFT)][data];
80102d57:	a1 bc b8 10 80       	mov    0x8010b8bc,%eax
80102d5c:	83 e0 03             	and    $0x3,%eax
80102d5f:	8b 14 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%edx
80102d66:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d69:	01 d0                	add    %edx,%eax
80102d6b:	8a 00                	mov    (%eax),%al
80102d6d:	0f b6 c0             	movzbl %al,%eax
80102d70:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102d73:	a1 bc b8 10 80       	mov    0x8010b8bc,%eax
80102d78:	83 e0 08             	and    $0x8,%eax
80102d7b:	85 c0                	test   %eax,%eax
80102d7d:	74 22                	je     80102da1 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102d7f:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102d83:	76 0c                	jbe    80102d91 <kbdgetc+0x13a>
80102d85:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102d89:	77 06                	ja     80102d91 <kbdgetc+0x13a>
      c += 'A' - 'a';
80102d8b:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102d8f:	eb 10                	jmp    80102da1 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102d91:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102d95:	76 0a                	jbe    80102da1 <kbdgetc+0x14a>
80102d97:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102d9b:	77 04                	ja     80102da1 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102d9d:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102da1:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102da4:	c9                   	leave  
80102da5:	c3                   	ret    

80102da6 <kbdintr>:

void
kbdintr(void)
{
80102da6:	55                   	push   %ebp
80102da7:	89 e5                	mov    %esp,%ebp
80102da9:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102dac:	c7 04 24 57 2c 10 80 	movl   $0x80102c57,(%esp)
80102db3:	e8 3d da ff ff       	call   801007f5 <consoleintr>
}
80102db8:	c9                   	leave  
80102db9:	c3                   	ret    
	...

80102dbc <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102dbc:	55                   	push   %ebp
80102dbd:	89 e5                	mov    %esp,%ebp
80102dbf:	83 ec 14             	sub    $0x14,%esp
80102dc2:	8b 45 08             	mov    0x8(%ebp),%eax
80102dc5:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102dc9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102dcc:	89 c2                	mov    %eax,%edx
80102dce:	ec                   	in     (%dx),%al
80102dcf:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102dd2:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80102dd5:	c9                   	leave  
80102dd6:	c3                   	ret    

80102dd7 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102dd7:	55                   	push   %ebp
80102dd8:	89 e5                	mov    %esp,%ebp
80102dda:	83 ec 08             	sub    $0x8,%esp
80102ddd:	8b 45 08             	mov    0x8(%ebp),%eax
80102de0:	8b 55 0c             	mov    0xc(%ebp),%edx
80102de3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102de7:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102dea:	8a 45 f8             	mov    -0x8(%ebp),%al
80102ded:	8b 55 fc             	mov    -0x4(%ebp),%edx
80102df0:	ee                   	out    %al,(%dx)
}
80102df1:	c9                   	leave  
80102df2:	c3                   	ret    

80102df3 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102df3:	55                   	push   %ebp
80102df4:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102df6:	a1 9c 39 11 80       	mov    0x8011399c,%eax
80102dfb:	8b 55 08             	mov    0x8(%ebp),%edx
80102dfe:	c1 e2 02             	shl    $0x2,%edx
80102e01:	01 c2                	add    %eax,%edx
80102e03:	8b 45 0c             	mov    0xc(%ebp),%eax
80102e06:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102e08:	a1 9c 39 11 80       	mov    0x8011399c,%eax
80102e0d:	83 c0 20             	add    $0x20,%eax
80102e10:	8b 00                	mov    (%eax),%eax
}
80102e12:	5d                   	pop    %ebp
80102e13:	c3                   	ret    

80102e14 <lapicinit>:

void
lapicinit(void)
{
80102e14:	55                   	push   %ebp
80102e15:	89 e5                	mov    %esp,%ebp
80102e17:	83 ec 08             	sub    $0x8,%esp
  if(!lapic)
80102e1a:	a1 9c 39 11 80       	mov    0x8011399c,%eax
80102e1f:	85 c0                	test   %eax,%eax
80102e21:	75 05                	jne    80102e28 <lapicinit+0x14>
    return;
80102e23:	e9 43 01 00 00       	jmp    80102f6b <lapicinit+0x157>

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102e28:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80102e2f:	00 
80102e30:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80102e37:	e8 b7 ff ff ff       	call   80102df3 <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102e3c:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
80102e43:	00 
80102e44:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80102e4b:	e8 a3 ff ff ff       	call   80102df3 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102e50:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80102e57:	00 
80102e58:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102e5f:	e8 8f ff ff ff       	call   80102df3 <lapicw>
  lapicw(TICR, 10000000);
80102e64:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80102e6b:	00 
80102e6c:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
80102e73:	e8 7b ff ff ff       	call   80102df3 <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102e78:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102e7f:	00 
80102e80:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
80102e87:	e8 67 ff ff ff       	call   80102df3 <lapicw>
  lapicw(LINT1, MASKED);
80102e8c:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102e93:	00 
80102e94:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80102e9b:	e8 53 ff ff ff       	call   80102df3 <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102ea0:	a1 9c 39 11 80       	mov    0x8011399c,%eax
80102ea5:	83 c0 30             	add    $0x30,%eax
80102ea8:	8b 00                	mov    (%eax),%eax
80102eaa:	c1 e8 10             	shr    $0x10,%eax
80102ead:	0f b6 c0             	movzbl %al,%eax
80102eb0:	83 f8 03             	cmp    $0x3,%eax
80102eb3:	76 14                	jbe    80102ec9 <lapicinit+0xb5>
    lapicw(PCINT, MASKED);
80102eb5:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102ebc:	00 
80102ebd:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80102ec4:	e8 2a ff ff ff       	call   80102df3 <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102ec9:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80102ed0:	00 
80102ed1:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80102ed8:	e8 16 ff ff ff       	call   80102df3 <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102edd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102ee4:	00 
80102ee5:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102eec:	e8 02 ff ff ff       	call   80102df3 <lapicw>
  lapicw(ESR, 0);
80102ef1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102ef8:	00 
80102ef9:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102f00:	e8 ee fe ff ff       	call   80102df3 <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102f05:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102f0c:	00 
80102f0d:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102f14:	e8 da fe ff ff       	call   80102df3 <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102f19:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102f20:	00 
80102f21:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102f28:	e8 c6 fe ff ff       	call   80102df3 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102f2d:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
80102f34:	00 
80102f35:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102f3c:	e8 b2 fe ff ff       	call   80102df3 <lapicw>
  while(lapic[ICRLO] & DELIVS)
80102f41:	90                   	nop
80102f42:	a1 9c 39 11 80       	mov    0x8011399c,%eax
80102f47:	05 00 03 00 00       	add    $0x300,%eax
80102f4c:	8b 00                	mov    (%eax),%eax
80102f4e:	25 00 10 00 00       	and    $0x1000,%eax
80102f53:	85 c0                	test   %eax,%eax
80102f55:	75 eb                	jne    80102f42 <lapicinit+0x12e>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102f57:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102f5e:	00 
80102f5f:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80102f66:	e8 88 fe ff ff       	call   80102df3 <lapicw>
}
80102f6b:	c9                   	leave  
80102f6c:	c3                   	ret    

80102f6d <lapicid>:

int
lapicid(void)
{
80102f6d:	55                   	push   %ebp
80102f6e:	89 e5                	mov    %esp,%ebp
  if (!lapic)
80102f70:	a1 9c 39 11 80       	mov    0x8011399c,%eax
80102f75:	85 c0                	test   %eax,%eax
80102f77:	75 07                	jne    80102f80 <lapicid+0x13>
    return 0;
80102f79:	b8 00 00 00 00       	mov    $0x0,%eax
80102f7e:	eb 0d                	jmp    80102f8d <lapicid+0x20>
  return lapic[ID] >> 24;
80102f80:	a1 9c 39 11 80       	mov    0x8011399c,%eax
80102f85:	83 c0 20             	add    $0x20,%eax
80102f88:	8b 00                	mov    (%eax),%eax
80102f8a:	c1 e8 18             	shr    $0x18,%eax
}
80102f8d:	5d                   	pop    %ebp
80102f8e:	c3                   	ret    

80102f8f <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102f8f:	55                   	push   %ebp
80102f90:	89 e5                	mov    %esp,%ebp
80102f92:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
80102f95:	a1 9c 39 11 80       	mov    0x8011399c,%eax
80102f9a:	85 c0                	test   %eax,%eax
80102f9c:	74 14                	je     80102fb2 <lapiceoi+0x23>
    lapicw(EOI, 0);
80102f9e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102fa5:	00 
80102fa6:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102fad:	e8 41 fe ff ff       	call   80102df3 <lapicw>
}
80102fb2:	c9                   	leave  
80102fb3:	c3                   	ret    

80102fb4 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102fb4:	55                   	push   %ebp
80102fb5:	89 e5                	mov    %esp,%ebp
}
80102fb7:	5d                   	pop    %ebp
80102fb8:	c3                   	ret    

80102fb9 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102fb9:	55                   	push   %ebp
80102fba:	89 e5                	mov    %esp,%ebp
80102fbc:	83 ec 1c             	sub    $0x1c,%esp
80102fbf:	8b 45 08             	mov    0x8(%ebp),%eax
80102fc2:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102fc5:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80102fcc:	00 
80102fcd:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80102fd4:	e8 fe fd ff ff       	call   80102dd7 <outb>
  outb(CMOS_PORT+1, 0x0A);
80102fd9:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80102fe0:	00 
80102fe1:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80102fe8:	e8 ea fd ff ff       	call   80102dd7 <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102fed:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102ff4:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102ff7:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102ffc:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102fff:	8d 50 02             	lea    0x2(%eax),%edx
80103002:	8b 45 0c             	mov    0xc(%ebp),%eax
80103005:	c1 e8 04             	shr    $0x4,%eax
80103008:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
8010300b:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010300f:	c1 e0 18             	shl    $0x18,%eax
80103012:	89 44 24 04          	mov    %eax,0x4(%esp)
80103016:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
8010301d:	e8 d1 fd ff ff       	call   80102df3 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80103022:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
80103029:	00 
8010302a:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103031:	e8 bd fd ff ff       	call   80102df3 <lapicw>
  microdelay(200);
80103036:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
8010303d:	e8 72 ff ff ff       	call   80102fb4 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
80103042:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
80103049:	00 
8010304a:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103051:	e8 9d fd ff ff       	call   80102df3 <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80103056:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
8010305d:	e8 52 ff ff ff       	call   80102fb4 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103062:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103069:	eb 3f                	jmp    801030aa <lapicstartap+0xf1>
    lapicw(ICRHI, apicid<<24);
8010306b:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010306f:	c1 e0 18             	shl    $0x18,%eax
80103072:	89 44 24 04          	mov    %eax,0x4(%esp)
80103076:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
8010307d:	e8 71 fd ff ff       	call   80102df3 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80103082:	8b 45 0c             	mov    0xc(%ebp),%eax
80103085:	c1 e8 0c             	shr    $0xc,%eax
80103088:	80 cc 06             	or     $0x6,%ah
8010308b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010308f:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103096:	e8 58 fd ff ff       	call   80102df3 <lapicw>
    microdelay(200);
8010309b:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801030a2:	e8 0d ff ff ff       	call   80102fb4 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801030a7:	ff 45 fc             	incl   -0x4(%ebp)
801030aa:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
801030ae:	7e bb                	jle    8010306b <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
801030b0:	c9                   	leave  
801030b1:	c3                   	ret    

801030b2 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
801030b2:	55                   	push   %ebp
801030b3:	89 e5                	mov    %esp,%ebp
801030b5:	83 ec 08             	sub    $0x8,%esp
  outb(CMOS_PORT,  reg);
801030b8:	8b 45 08             	mov    0x8(%ebp),%eax
801030bb:	0f b6 c0             	movzbl %al,%eax
801030be:	89 44 24 04          	mov    %eax,0x4(%esp)
801030c2:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
801030c9:	e8 09 fd ff ff       	call   80102dd7 <outb>
  microdelay(200);
801030ce:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801030d5:	e8 da fe ff ff       	call   80102fb4 <microdelay>

  return inb(CMOS_RETURN);
801030da:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
801030e1:	e8 d6 fc ff ff       	call   80102dbc <inb>
801030e6:	0f b6 c0             	movzbl %al,%eax
}
801030e9:	c9                   	leave  
801030ea:	c3                   	ret    

801030eb <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
801030eb:	55                   	push   %ebp
801030ec:	89 e5                	mov    %esp,%ebp
801030ee:	83 ec 04             	sub    $0x4,%esp
  r->second = cmos_read(SECS);
801030f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801030f8:	e8 b5 ff ff ff       	call   801030b2 <cmos_read>
801030fd:	8b 55 08             	mov    0x8(%ebp),%edx
80103100:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80103102:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80103109:	e8 a4 ff ff ff       	call   801030b2 <cmos_read>
8010310e:	8b 55 08             	mov    0x8(%ebp),%edx
80103111:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80103114:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
8010311b:	e8 92 ff ff ff       	call   801030b2 <cmos_read>
80103120:	8b 55 08             	mov    0x8(%ebp),%edx
80103123:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80103126:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
8010312d:	e8 80 ff ff ff       	call   801030b2 <cmos_read>
80103132:	8b 55 08             	mov    0x8(%ebp),%edx
80103135:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80103138:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010313f:	e8 6e ff ff ff       	call   801030b2 <cmos_read>
80103144:	8b 55 08             	mov    0x8(%ebp),%edx
80103147:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
8010314a:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
80103151:	e8 5c ff ff ff       	call   801030b2 <cmos_read>
80103156:	8b 55 08             	mov    0x8(%ebp),%edx
80103159:	89 42 14             	mov    %eax,0x14(%edx)
}
8010315c:	c9                   	leave  
8010315d:	c3                   	ret    

8010315e <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
8010315e:	55                   	push   %ebp
8010315f:	89 e5                	mov    %esp,%ebp
80103161:	57                   	push   %edi
80103162:	56                   	push   %esi
80103163:	53                   	push   %ebx
80103164:	83 ec 5c             	sub    $0x5c,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80103167:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
8010316e:	e8 3f ff ff ff       	call   801030b2 <cmos_read>
80103173:	89 45 e4             	mov    %eax,-0x1c(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80103176:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103179:	83 e0 04             	and    $0x4,%eax
8010317c:	85 c0                	test   %eax,%eax
8010317e:	0f 94 c0             	sete   %al
80103181:	0f b6 c0             	movzbl %al,%eax
80103184:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80103187:	8d 45 c8             	lea    -0x38(%ebp),%eax
8010318a:	89 04 24             	mov    %eax,(%esp)
8010318d:	e8 59 ff ff ff       	call   801030eb <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80103192:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80103199:	e8 14 ff ff ff       	call   801030b2 <cmos_read>
8010319e:	25 80 00 00 00       	and    $0x80,%eax
801031a3:	85 c0                	test   %eax,%eax
801031a5:	74 02                	je     801031a9 <cmostime+0x4b>
        continue;
801031a7:	eb 36                	jmp    801031df <cmostime+0x81>
    fill_rtcdate(&t2);
801031a9:	8d 45 b0             	lea    -0x50(%ebp),%eax
801031ac:	89 04 24             	mov    %eax,(%esp)
801031af:	e8 37 ff ff ff       	call   801030eb <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
801031b4:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
801031bb:	00 
801031bc:	8d 45 b0             	lea    -0x50(%ebp),%eax
801031bf:	89 44 24 04          	mov    %eax,0x4(%esp)
801031c3:	8d 45 c8             	lea    -0x38(%ebp),%eax
801031c6:	89 04 24             	mov    %eax,(%esp)
801031c9:	e8 d7 1e 00 00       	call   801050a5 <memcmp>
801031ce:	85 c0                	test   %eax,%eax
801031d0:	75 0d                	jne    801031df <cmostime+0x81>
      break;
801031d2:	90                   	nop
  }

  // convert
  if(bcd) {
801031d3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801031d7:	0f 84 ac 00 00 00    	je     80103289 <cmostime+0x12b>
801031dd:	eb 02                	jmp    801031e1 <cmostime+0x83>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
801031df:	eb a6                	jmp    80103187 <cmostime+0x29>

  // convert
  if(bcd) {
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801031e1:	8b 45 c8             	mov    -0x38(%ebp),%eax
801031e4:	c1 e8 04             	shr    $0x4,%eax
801031e7:	89 c2                	mov    %eax,%edx
801031e9:	89 d0                	mov    %edx,%eax
801031eb:	c1 e0 02             	shl    $0x2,%eax
801031ee:	01 d0                	add    %edx,%eax
801031f0:	01 c0                	add    %eax,%eax
801031f2:	8b 55 c8             	mov    -0x38(%ebp),%edx
801031f5:	83 e2 0f             	and    $0xf,%edx
801031f8:	01 d0                	add    %edx,%eax
801031fa:	89 45 c8             	mov    %eax,-0x38(%ebp)
    CONV(minute);
801031fd:	8b 45 cc             	mov    -0x34(%ebp),%eax
80103200:	c1 e8 04             	shr    $0x4,%eax
80103203:	89 c2                	mov    %eax,%edx
80103205:	89 d0                	mov    %edx,%eax
80103207:	c1 e0 02             	shl    $0x2,%eax
8010320a:	01 d0                	add    %edx,%eax
8010320c:	01 c0                	add    %eax,%eax
8010320e:	8b 55 cc             	mov    -0x34(%ebp),%edx
80103211:	83 e2 0f             	and    $0xf,%edx
80103214:	01 d0                	add    %edx,%eax
80103216:	89 45 cc             	mov    %eax,-0x34(%ebp)
    CONV(hour  );
80103219:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010321c:	c1 e8 04             	shr    $0x4,%eax
8010321f:	89 c2                	mov    %eax,%edx
80103221:	89 d0                	mov    %edx,%eax
80103223:	c1 e0 02             	shl    $0x2,%eax
80103226:	01 d0                	add    %edx,%eax
80103228:	01 c0                	add    %eax,%eax
8010322a:	8b 55 d0             	mov    -0x30(%ebp),%edx
8010322d:	83 e2 0f             	and    $0xf,%edx
80103230:	01 d0                	add    %edx,%eax
80103232:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(day   );
80103235:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80103238:	c1 e8 04             	shr    $0x4,%eax
8010323b:	89 c2                	mov    %eax,%edx
8010323d:	89 d0                	mov    %edx,%eax
8010323f:	c1 e0 02             	shl    $0x2,%eax
80103242:	01 d0                	add    %edx,%eax
80103244:	01 c0                	add    %eax,%eax
80103246:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80103249:	83 e2 0f             	and    $0xf,%edx
8010324c:	01 d0                	add    %edx,%eax
8010324e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(month );
80103251:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103254:	c1 e8 04             	shr    $0x4,%eax
80103257:	89 c2                	mov    %eax,%edx
80103259:	89 d0                	mov    %edx,%eax
8010325b:	c1 e0 02             	shl    $0x2,%eax
8010325e:	01 d0                	add    %edx,%eax
80103260:	01 c0                	add    %eax,%eax
80103262:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103265:	83 e2 0f             	and    $0xf,%edx
80103268:	01 d0                	add    %edx,%eax
8010326a:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(year  );
8010326d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103270:	c1 e8 04             	shr    $0x4,%eax
80103273:	89 c2                	mov    %eax,%edx
80103275:	89 d0                	mov    %edx,%eax
80103277:	c1 e0 02             	shl    $0x2,%eax
8010327a:	01 d0                	add    %edx,%eax
8010327c:	01 c0                	add    %eax,%eax
8010327e:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103281:	83 e2 0f             	and    $0xf,%edx
80103284:	01 d0                	add    %edx,%eax
80103286:	89 45 dc             	mov    %eax,-0x24(%ebp)
#undef     CONV
  }

  *r = t1;
80103289:	8b 45 08             	mov    0x8(%ebp),%eax
8010328c:	89 c2                	mov    %eax,%edx
8010328e:	8d 5d c8             	lea    -0x38(%ebp),%ebx
80103291:	b8 06 00 00 00       	mov    $0x6,%eax
80103296:	89 d7                	mov    %edx,%edi
80103298:	89 de                	mov    %ebx,%esi
8010329a:	89 c1                	mov    %eax,%ecx
8010329c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  r->year += 2000;
8010329e:	8b 45 08             	mov    0x8(%ebp),%eax
801032a1:	8b 40 14             	mov    0x14(%eax),%eax
801032a4:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
801032aa:	8b 45 08             	mov    0x8(%ebp),%eax
801032ad:	89 50 14             	mov    %edx,0x14(%eax)
}
801032b0:	83 c4 5c             	add    $0x5c,%esp
801032b3:	5b                   	pop    %ebx
801032b4:	5e                   	pop    %esi
801032b5:	5f                   	pop    %edi
801032b6:	5d                   	pop    %ebp
801032b7:	c3                   	ret    

801032b8 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
801032b8:	55                   	push   %ebp
801032b9:	89 e5                	mov    %esp,%ebp
801032bb:	83 ec 38             	sub    $0x38,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
801032be:	c7 44 24 04 29 8a 10 	movl   $0x80108a29,0x4(%esp)
801032c5:	80 
801032c6:	c7 04 24 a0 39 11 80 	movl   $0x801139a0,(%esp)
801032cd:	e8 d8 1a 00 00       	call   80104daa <initlock>
  readsb(dev, &sb);
801032d2:	8d 45 dc             	lea    -0x24(%ebp),%eax
801032d5:	89 44 24 04          	mov    %eax,0x4(%esp)
801032d9:	8b 45 08             	mov    0x8(%ebp),%eax
801032dc:	89 04 24             	mov    %eax,(%esp)
801032df:	e8 d8 e0 ff ff       	call   801013bc <readsb>
  log.start = sb.logstart;
801032e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032e7:	a3 d4 39 11 80       	mov    %eax,0x801139d4
  log.size = sb.nlog;
801032ec:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032ef:	a3 d8 39 11 80       	mov    %eax,0x801139d8
  log.dev = dev;
801032f4:	8b 45 08             	mov    0x8(%ebp),%eax
801032f7:	a3 e4 39 11 80       	mov    %eax,0x801139e4
  recover_from_log();
801032fc:	e8 95 01 00 00       	call   80103496 <recover_from_log>
}
80103301:	c9                   	leave  
80103302:	c3                   	ret    

80103303 <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80103303:	55                   	push   %ebp
80103304:	89 e5                	mov    %esp,%ebp
80103306:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103309:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103310:	e9 89 00 00 00       	jmp    8010339e <install_trans+0x9b>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103315:	8b 15 d4 39 11 80    	mov    0x801139d4,%edx
8010331b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010331e:	01 d0                	add    %edx,%eax
80103320:	40                   	inc    %eax
80103321:	89 c2                	mov    %eax,%edx
80103323:	a1 e4 39 11 80       	mov    0x801139e4,%eax
80103328:	89 54 24 04          	mov    %edx,0x4(%esp)
8010332c:	89 04 24             	mov    %eax,(%esp)
8010332f:	e8 81 ce ff ff       	call   801001b5 <bread>
80103334:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103337:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010333a:	83 c0 10             	add    $0x10,%eax
8010333d:	8b 04 85 ac 39 11 80 	mov    -0x7feec654(,%eax,4),%eax
80103344:	89 c2                	mov    %eax,%edx
80103346:	a1 e4 39 11 80       	mov    0x801139e4,%eax
8010334b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010334f:	89 04 24             	mov    %eax,(%esp)
80103352:	e8 5e ce ff ff       	call   801001b5 <bread>
80103357:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
8010335a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010335d:	8d 50 5c             	lea    0x5c(%eax),%edx
80103360:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103363:	83 c0 5c             	add    $0x5c,%eax
80103366:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010336d:	00 
8010336e:	89 54 24 04          	mov    %edx,0x4(%esp)
80103372:	89 04 24             	mov    %eax,(%esp)
80103375:	e8 7d 1d 00 00       	call   801050f7 <memmove>
    bwrite(dbuf);  // write dst to disk
8010337a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010337d:	89 04 24             	mov    %eax,(%esp)
80103380:	e8 67 ce ff ff       	call   801001ec <bwrite>
    brelse(lbuf);
80103385:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103388:	89 04 24             	mov    %eax,(%esp)
8010338b:	e8 9c ce ff ff       	call   8010022c <brelse>
    brelse(dbuf);
80103390:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103393:	89 04 24             	mov    %eax,(%esp)
80103396:	e8 91 ce ff ff       	call   8010022c <brelse>
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010339b:	ff 45 f4             	incl   -0xc(%ebp)
8010339e:	a1 e8 39 11 80       	mov    0x801139e8,%eax
801033a3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801033a6:	0f 8f 69 ff ff ff    	jg     80103315 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf);
    brelse(dbuf);
  }
}
801033ac:	c9                   	leave  
801033ad:	c3                   	ret    

801033ae <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801033ae:	55                   	push   %ebp
801033af:	89 e5                	mov    %esp,%ebp
801033b1:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
801033b4:	a1 d4 39 11 80       	mov    0x801139d4,%eax
801033b9:	89 c2                	mov    %eax,%edx
801033bb:	a1 e4 39 11 80       	mov    0x801139e4,%eax
801033c0:	89 54 24 04          	mov    %edx,0x4(%esp)
801033c4:	89 04 24             	mov    %eax,(%esp)
801033c7:	e8 e9 cd ff ff       	call   801001b5 <bread>
801033cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
801033cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033d2:	83 c0 5c             	add    $0x5c,%eax
801033d5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
801033d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033db:	8b 00                	mov    (%eax),%eax
801033dd:	a3 e8 39 11 80       	mov    %eax,0x801139e8
  for (i = 0; i < log.lh.n; i++) {
801033e2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801033e9:	eb 1a                	jmp    80103405 <read_head+0x57>
    log.lh.block[i] = lh->block[i];
801033eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
801033f1:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
801033f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801033f8:	83 c2 10             	add    $0x10,%edx
801033fb:	89 04 95 ac 39 11 80 	mov    %eax,-0x7feec654(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80103402:	ff 45 f4             	incl   -0xc(%ebp)
80103405:	a1 e8 39 11 80       	mov    0x801139e8,%eax
8010340a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010340d:	7f dc                	jg     801033eb <read_head+0x3d>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
8010340f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103412:	89 04 24             	mov    %eax,(%esp)
80103415:	e8 12 ce ff ff       	call   8010022c <brelse>
}
8010341a:	c9                   	leave  
8010341b:	c3                   	ret    

8010341c <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
8010341c:	55                   	push   %ebp
8010341d:	89 e5                	mov    %esp,%ebp
8010341f:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103422:	a1 d4 39 11 80       	mov    0x801139d4,%eax
80103427:	89 c2                	mov    %eax,%edx
80103429:	a1 e4 39 11 80       	mov    0x801139e4,%eax
8010342e:	89 54 24 04          	mov    %edx,0x4(%esp)
80103432:	89 04 24             	mov    %eax,(%esp)
80103435:	e8 7b cd ff ff       	call   801001b5 <bread>
8010343a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
8010343d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103440:	83 c0 5c             	add    $0x5c,%eax
80103443:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103446:	8b 15 e8 39 11 80    	mov    0x801139e8,%edx
8010344c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010344f:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103451:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103458:	eb 1a                	jmp    80103474 <write_head+0x58>
    hb->block[i] = log.lh.block[i];
8010345a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010345d:	83 c0 10             	add    $0x10,%eax
80103460:	8b 0c 85 ac 39 11 80 	mov    -0x7feec654(,%eax,4),%ecx
80103467:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010346a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010346d:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80103471:	ff 45 f4             	incl   -0xc(%ebp)
80103474:	a1 e8 39 11 80       	mov    0x801139e8,%eax
80103479:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010347c:	7f dc                	jg     8010345a <write_head+0x3e>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
8010347e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103481:	89 04 24             	mov    %eax,(%esp)
80103484:	e8 63 cd ff ff       	call   801001ec <bwrite>
  brelse(buf);
80103489:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010348c:	89 04 24             	mov    %eax,(%esp)
8010348f:	e8 98 cd ff ff       	call   8010022c <brelse>
}
80103494:	c9                   	leave  
80103495:	c3                   	ret    

80103496 <recover_from_log>:

static void
recover_from_log(void)
{
80103496:	55                   	push   %ebp
80103497:	89 e5                	mov    %esp,%ebp
80103499:	83 ec 08             	sub    $0x8,%esp
  read_head();
8010349c:	e8 0d ff ff ff       	call   801033ae <read_head>
  install_trans(); // if committed, copy from log to disk
801034a1:	e8 5d fe ff ff       	call   80103303 <install_trans>
  log.lh.n = 0;
801034a6:	c7 05 e8 39 11 80 00 	movl   $0x0,0x801139e8
801034ad:	00 00 00 
  write_head(); // clear the log
801034b0:	e8 67 ff ff ff       	call   8010341c <write_head>
}
801034b5:	c9                   	leave  
801034b6:	c3                   	ret    

801034b7 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
801034b7:	55                   	push   %ebp
801034b8:	89 e5                	mov    %esp,%ebp
801034ba:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
801034bd:	c7 04 24 a0 39 11 80 	movl   $0x801139a0,(%esp)
801034c4:	e8 02 19 00 00       	call   80104dcb <acquire>
  while(1){
    if(log.committing){
801034c9:	a1 e0 39 11 80       	mov    0x801139e0,%eax
801034ce:	85 c0                	test   %eax,%eax
801034d0:	74 16                	je     801034e8 <begin_op+0x31>
      sleep(&log, &log.lock);
801034d2:	c7 44 24 04 a0 39 11 	movl   $0x801139a0,0x4(%esp)
801034d9:	80 
801034da:	c7 04 24 a0 39 11 80 	movl   $0x801139a0,(%esp)
801034e1:	e8 17 15 00 00       	call   801049fd <sleep>
801034e6:	eb 4d                	jmp    80103535 <begin_op+0x7e>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801034e8:	8b 15 e8 39 11 80    	mov    0x801139e8,%edx
801034ee:	a1 dc 39 11 80       	mov    0x801139dc,%eax
801034f3:	8d 48 01             	lea    0x1(%eax),%ecx
801034f6:	89 c8                	mov    %ecx,%eax
801034f8:	c1 e0 02             	shl    $0x2,%eax
801034fb:	01 c8                	add    %ecx,%eax
801034fd:	01 c0                	add    %eax,%eax
801034ff:	01 d0                	add    %edx,%eax
80103501:	83 f8 1e             	cmp    $0x1e,%eax
80103504:	7e 16                	jle    8010351c <begin_op+0x65>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103506:	c7 44 24 04 a0 39 11 	movl   $0x801139a0,0x4(%esp)
8010350d:	80 
8010350e:	c7 04 24 a0 39 11 80 	movl   $0x801139a0,(%esp)
80103515:	e8 e3 14 00 00       	call   801049fd <sleep>
8010351a:	eb 19                	jmp    80103535 <begin_op+0x7e>
    } else {
      log.outstanding += 1;
8010351c:	a1 dc 39 11 80       	mov    0x801139dc,%eax
80103521:	40                   	inc    %eax
80103522:	a3 dc 39 11 80       	mov    %eax,0x801139dc
      release(&log.lock);
80103527:	c7 04 24 a0 39 11 80 	movl   $0x801139a0,(%esp)
8010352e:	e8 02 19 00 00       	call   80104e35 <release>
      break;
80103533:	eb 02                	jmp    80103537 <begin_op+0x80>
    }
  }
80103535:	eb 92                	jmp    801034c9 <begin_op+0x12>
}
80103537:	c9                   	leave  
80103538:	c3                   	ret    

80103539 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103539:	55                   	push   %ebp
8010353a:	89 e5                	mov    %esp,%ebp
8010353c:	83 ec 28             	sub    $0x28,%esp
  int do_commit = 0;
8010353f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103546:	c7 04 24 a0 39 11 80 	movl   $0x801139a0,(%esp)
8010354d:	e8 79 18 00 00       	call   80104dcb <acquire>
  log.outstanding -= 1;
80103552:	a1 dc 39 11 80       	mov    0x801139dc,%eax
80103557:	48                   	dec    %eax
80103558:	a3 dc 39 11 80       	mov    %eax,0x801139dc
  if(log.committing)
8010355d:	a1 e0 39 11 80       	mov    0x801139e0,%eax
80103562:	85 c0                	test   %eax,%eax
80103564:	74 0c                	je     80103572 <end_op+0x39>
    panic("log.committing");
80103566:	c7 04 24 2d 8a 10 80 	movl   $0x80108a2d,(%esp)
8010356d:	e8 e2 cf ff ff       	call   80100554 <panic>
  if(log.outstanding == 0){
80103572:	a1 dc 39 11 80       	mov    0x801139dc,%eax
80103577:	85 c0                	test   %eax,%eax
80103579:	75 13                	jne    8010358e <end_op+0x55>
    do_commit = 1;
8010357b:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103582:	c7 05 e0 39 11 80 01 	movl   $0x1,0x801139e0
80103589:	00 00 00 
8010358c:	eb 0c                	jmp    8010359a <end_op+0x61>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
8010358e:	c7 04 24 a0 39 11 80 	movl   $0x801139a0,(%esp)
80103595:	e8 37 15 00 00       	call   80104ad1 <wakeup>
  }
  release(&log.lock);
8010359a:	c7 04 24 a0 39 11 80 	movl   $0x801139a0,(%esp)
801035a1:	e8 8f 18 00 00       	call   80104e35 <release>

  if(do_commit){
801035a6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801035aa:	74 33                	je     801035df <end_op+0xa6>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
801035ac:	e8 db 00 00 00       	call   8010368c <commit>
    acquire(&log.lock);
801035b1:	c7 04 24 a0 39 11 80 	movl   $0x801139a0,(%esp)
801035b8:	e8 0e 18 00 00       	call   80104dcb <acquire>
    log.committing = 0;
801035bd:	c7 05 e0 39 11 80 00 	movl   $0x0,0x801139e0
801035c4:	00 00 00 
    wakeup(&log);
801035c7:	c7 04 24 a0 39 11 80 	movl   $0x801139a0,(%esp)
801035ce:	e8 fe 14 00 00       	call   80104ad1 <wakeup>
    release(&log.lock);
801035d3:	c7 04 24 a0 39 11 80 	movl   $0x801139a0,(%esp)
801035da:	e8 56 18 00 00       	call   80104e35 <release>
  }
}
801035df:	c9                   	leave  
801035e0:	c3                   	ret    

801035e1 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
801035e1:	55                   	push   %ebp
801035e2:	89 e5                	mov    %esp,%ebp
801035e4:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801035e7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801035ee:	e9 89 00 00 00       	jmp    8010367c <write_log+0x9b>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801035f3:	8b 15 d4 39 11 80    	mov    0x801139d4,%edx
801035f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035fc:	01 d0                	add    %edx,%eax
801035fe:	40                   	inc    %eax
801035ff:	89 c2                	mov    %eax,%edx
80103601:	a1 e4 39 11 80       	mov    0x801139e4,%eax
80103606:	89 54 24 04          	mov    %edx,0x4(%esp)
8010360a:	89 04 24             	mov    %eax,(%esp)
8010360d:	e8 a3 cb ff ff       	call   801001b5 <bread>
80103612:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103615:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103618:	83 c0 10             	add    $0x10,%eax
8010361b:	8b 04 85 ac 39 11 80 	mov    -0x7feec654(,%eax,4),%eax
80103622:	89 c2                	mov    %eax,%edx
80103624:	a1 e4 39 11 80       	mov    0x801139e4,%eax
80103629:	89 54 24 04          	mov    %edx,0x4(%esp)
8010362d:	89 04 24             	mov    %eax,(%esp)
80103630:	e8 80 cb ff ff       	call   801001b5 <bread>
80103635:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103638:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010363b:	8d 50 5c             	lea    0x5c(%eax),%edx
8010363e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103641:	83 c0 5c             	add    $0x5c,%eax
80103644:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010364b:	00 
8010364c:	89 54 24 04          	mov    %edx,0x4(%esp)
80103650:	89 04 24             	mov    %eax,(%esp)
80103653:	e8 9f 1a 00 00       	call   801050f7 <memmove>
    bwrite(to);  // write the log
80103658:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010365b:	89 04 24             	mov    %eax,(%esp)
8010365e:	e8 89 cb ff ff       	call   801001ec <bwrite>
    brelse(from);
80103663:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103666:	89 04 24             	mov    %eax,(%esp)
80103669:	e8 be cb ff ff       	call   8010022c <brelse>
    brelse(to);
8010366e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103671:	89 04 24             	mov    %eax,(%esp)
80103674:	e8 b3 cb ff ff       	call   8010022c <brelse>
static void
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103679:	ff 45 f4             	incl   -0xc(%ebp)
8010367c:	a1 e8 39 11 80       	mov    0x801139e8,%eax
80103681:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103684:	0f 8f 69 ff ff ff    	jg     801035f3 <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from);
    brelse(to);
  }
}
8010368a:	c9                   	leave  
8010368b:	c3                   	ret    

8010368c <commit>:

static void
commit()
{
8010368c:	55                   	push   %ebp
8010368d:	89 e5                	mov    %esp,%ebp
8010368f:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103692:	a1 e8 39 11 80       	mov    0x801139e8,%eax
80103697:	85 c0                	test   %eax,%eax
80103699:	7e 1e                	jle    801036b9 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
8010369b:	e8 41 ff ff ff       	call   801035e1 <write_log>
    write_head();    // Write header to disk -- the real commit
801036a0:	e8 77 fd ff ff       	call   8010341c <write_head>
    install_trans(); // Now install writes to home locations
801036a5:	e8 59 fc ff ff       	call   80103303 <install_trans>
    log.lh.n = 0;
801036aa:	c7 05 e8 39 11 80 00 	movl   $0x0,0x801139e8
801036b1:	00 00 00 
    write_head();    // Erase the transaction from the log
801036b4:	e8 63 fd ff ff       	call   8010341c <write_head>
  }
}
801036b9:	c9                   	leave  
801036ba:	c3                   	ret    

801036bb <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801036bb:	55                   	push   %ebp
801036bc:	89 e5                	mov    %esp,%ebp
801036be:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801036c1:	a1 e8 39 11 80       	mov    0x801139e8,%eax
801036c6:	83 f8 1d             	cmp    $0x1d,%eax
801036c9:	7f 10                	jg     801036db <log_write+0x20>
801036cb:	a1 e8 39 11 80       	mov    0x801139e8,%eax
801036d0:	8b 15 d8 39 11 80    	mov    0x801139d8,%edx
801036d6:	4a                   	dec    %edx
801036d7:	39 d0                	cmp    %edx,%eax
801036d9:	7c 0c                	jl     801036e7 <log_write+0x2c>
    panic("too big a transaction");
801036db:	c7 04 24 3c 8a 10 80 	movl   $0x80108a3c,(%esp)
801036e2:	e8 6d ce ff ff       	call   80100554 <panic>
  if (log.outstanding < 1)
801036e7:	a1 dc 39 11 80       	mov    0x801139dc,%eax
801036ec:	85 c0                	test   %eax,%eax
801036ee:	7f 0c                	jg     801036fc <log_write+0x41>
    panic("log_write outside of trans");
801036f0:	c7 04 24 52 8a 10 80 	movl   $0x80108a52,(%esp)
801036f7:	e8 58 ce ff ff       	call   80100554 <panic>

  acquire(&log.lock);
801036fc:	c7 04 24 a0 39 11 80 	movl   $0x801139a0,(%esp)
80103703:	e8 c3 16 00 00       	call   80104dcb <acquire>
  for (i = 0; i < log.lh.n; i++) {
80103708:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010370f:	eb 1e                	jmp    8010372f <log_write+0x74>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103711:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103714:	83 c0 10             	add    $0x10,%eax
80103717:	8b 04 85 ac 39 11 80 	mov    -0x7feec654(,%eax,4),%eax
8010371e:	89 c2                	mov    %eax,%edx
80103720:	8b 45 08             	mov    0x8(%ebp),%eax
80103723:	8b 40 08             	mov    0x8(%eax),%eax
80103726:	39 c2                	cmp    %eax,%edx
80103728:	75 02                	jne    8010372c <log_write+0x71>
      break;
8010372a:	eb 0d                	jmp    80103739 <log_write+0x7e>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
8010372c:	ff 45 f4             	incl   -0xc(%ebp)
8010372f:	a1 e8 39 11 80       	mov    0x801139e8,%eax
80103734:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103737:	7f d8                	jg     80103711 <log_write+0x56>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
  }
  log.lh.block[i] = b->blockno;
80103739:	8b 45 08             	mov    0x8(%ebp),%eax
8010373c:	8b 40 08             	mov    0x8(%eax),%eax
8010373f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103742:	83 c2 10             	add    $0x10,%edx
80103745:	89 04 95 ac 39 11 80 	mov    %eax,-0x7feec654(,%edx,4)
  if (i == log.lh.n)
8010374c:	a1 e8 39 11 80       	mov    0x801139e8,%eax
80103751:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103754:	75 0b                	jne    80103761 <log_write+0xa6>
    log.lh.n++;
80103756:	a1 e8 39 11 80       	mov    0x801139e8,%eax
8010375b:	40                   	inc    %eax
8010375c:	a3 e8 39 11 80       	mov    %eax,0x801139e8
  b->flags |= B_DIRTY; // prevent eviction
80103761:	8b 45 08             	mov    0x8(%ebp),%eax
80103764:	8b 00                	mov    (%eax),%eax
80103766:	83 c8 04             	or     $0x4,%eax
80103769:	89 c2                	mov    %eax,%edx
8010376b:	8b 45 08             	mov    0x8(%ebp),%eax
8010376e:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103770:	c7 04 24 a0 39 11 80 	movl   $0x801139a0,(%esp)
80103777:	e8 b9 16 00 00       	call   80104e35 <release>
}
8010377c:	c9                   	leave  
8010377d:	c3                   	ret    
	...

80103780 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103780:	55                   	push   %ebp
80103781:	89 e5                	mov    %esp,%ebp
80103783:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103786:	8b 55 08             	mov    0x8(%ebp),%edx
80103789:	8b 45 0c             	mov    0xc(%ebp),%eax
8010378c:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010378f:	f0 87 02             	lock xchg %eax,(%edx)
80103792:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103795:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103798:	c9                   	leave  
80103799:	c3                   	ret    

8010379a <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
8010379a:	55                   	push   %ebp
8010379b:	89 e5                	mov    %esp,%ebp
8010379d:	83 e4 f0             	and    $0xfffffff0,%esp
801037a0:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801037a3:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
801037aa:	80 
801037ab:	c7 04 24 50 69 11 80 	movl   $0x80116950,(%esp)
801037b2:	e8 0d f3 ff ff       	call   80102ac4 <kinit1>
  kvmalloc();      // kernel page table
801037b7:	e8 e3 44 00 00       	call   80107c9f <kvmalloc>
  mpinit();        // detect other processors
801037bc:	e8 c4 03 00 00       	call   80103b85 <mpinit>
  lapicinit();     // interrupt controller
801037c1:	e8 4e f6 ff ff       	call   80102e14 <lapicinit>
  seginit();       // segment descriptors
801037c6:	e8 bc 3f 00 00       	call   80107787 <seginit>
  picinit();       // disable pic
801037cb:	e8 04 05 00 00       	call   80103cd4 <picinit>
  ioapicinit();    // another interrupt controller
801037d0:	e8 0c f2 ff ff       	call   801029e1 <ioapicinit>
  consoleinit();   // console hardware
801037d5:	e8 76 d3 ff ff       	call   80100b50 <consoleinit>
  uartinit();      // serial port
801037da:	e8 34 33 00 00       	call   80106b13 <uartinit>
  pinit();         // process table
801037df:	e8 e6 08 00 00       	call   801040ca <pinit>
  tvinit();        // trap vectors
801037e4:	e8 f7 2e 00 00       	call   801066e0 <tvinit>
  binit();         // buffer cache
801037e9:	e8 46 c8 ff ff       	call   80100034 <binit>
  fileinit();      // file table
801037ee:	e8 ed d7 ff ff       	call   80100fe0 <fileinit>
  ideinit();       // disk 
801037f3:	e8 f5 ed ff ff       	call   801025ed <ideinit>
  startothers();   // start other processors
801037f8:	e8 83 00 00 00       	call   80103880 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801037fd:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
80103804:	8e 
80103805:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
8010380c:	e8 eb f2 ff ff       	call   80102afc <kinit2>
  userinit();      // first user process
80103811:	e8 ce 0a 00 00       	call   801042e4 <userinit>
  mpmain();        // finish this processor's setup
80103816:	e8 1a 00 00 00       	call   80103835 <mpmain>

8010381b <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
8010381b:	55                   	push   %ebp
8010381c:	89 e5                	mov    %esp,%ebp
8010381e:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103821:	e8 90 44 00 00       	call   80107cb6 <switchkvm>
  seginit();
80103826:	e8 5c 3f 00 00       	call   80107787 <seginit>
  lapicinit();
8010382b:	e8 e4 f5 ff ff       	call   80102e14 <lapicinit>
  mpmain();
80103830:	e8 00 00 00 00       	call   80103835 <mpmain>

80103835 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103835:	55                   	push   %ebp
80103836:	89 e5                	mov    %esp,%ebp
80103838:	53                   	push   %ebx
80103839:	83 ec 14             	sub    $0x14,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
8010383c:	e8 a5 08 00 00       	call   801040e6 <cpuid>
80103841:	89 c3                	mov    %eax,%ebx
80103843:	e8 9e 08 00 00       	call   801040e6 <cpuid>
80103848:	89 5c 24 08          	mov    %ebx,0x8(%esp)
8010384c:	89 44 24 04          	mov    %eax,0x4(%esp)
80103850:	c7 04 24 6d 8a 10 80 	movl   $0x80108a6d,(%esp)
80103857:	e8 65 cb ff ff       	call   801003c1 <cprintf>
  idtinit();       // load idt register
8010385c:	e8 dc 2f 00 00       	call   8010683d <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103861:	e8 c5 08 00 00       	call   8010412b <mycpu>
80103866:	05 a0 00 00 00       	add    $0xa0,%eax
8010386b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80103872:	00 
80103873:	89 04 24             	mov    %eax,(%esp)
80103876:	e8 05 ff ff ff       	call   80103780 <xchg>
  scheduler();     // start running processes
8010387b:	e8 b3 0f 00 00       	call   80104833 <scheduler>

80103880 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103880:	55                   	push   %ebp
80103881:	89 e5                	mov    %esp,%ebp
80103883:	83 ec 28             	sub    $0x28,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103886:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
8010388d:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103892:	89 44 24 08          	mov    %eax,0x8(%esp)
80103896:	c7 44 24 04 2c b5 10 	movl   $0x8010b52c,0x4(%esp)
8010389d:	80 
8010389e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038a1:	89 04 24             	mov    %eax,(%esp)
801038a4:	e8 4e 18 00 00       	call   801050f7 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
801038a9:	c7 45 f4 a0 3a 11 80 	movl   $0x80113aa0,-0xc(%ebp)
801038b0:	eb 75                	jmp    80103927 <startothers+0xa7>
    if(c == mycpu())  // We've started already.
801038b2:	e8 74 08 00 00       	call   8010412b <mycpu>
801038b7:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801038ba:	75 02                	jne    801038be <startothers+0x3e>
      continue;
801038bc:	eb 62                	jmp    80103920 <startothers+0xa0>

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801038be:	e8 2c f3 ff ff       	call   80102bef <kalloc>
801038c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801038c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038c9:	83 e8 04             	sub    $0x4,%eax
801038cc:	8b 55 ec             	mov    -0x14(%ebp),%edx
801038cf:	81 c2 00 10 00 00    	add    $0x1000,%edx
801038d5:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
801038d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038da:	83 e8 08             	sub    $0x8,%eax
801038dd:	c7 00 1b 38 10 80    	movl   $0x8010381b,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801038e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038e6:	8d 50 f4             	lea    -0xc(%eax),%edx
801038e9:	b8 00 a0 10 80       	mov    $0x8010a000,%eax
801038ee:	05 00 00 00 80       	add    $0x80000000,%eax
801038f3:	89 02                	mov    %eax,(%edx)

    lapicstartap(c->apicid, V2P(code));
801038f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038f8:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801038fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103901:	8a 00                	mov    (%eax),%al
80103903:	0f b6 c0             	movzbl %al,%eax
80103906:	89 54 24 04          	mov    %edx,0x4(%esp)
8010390a:	89 04 24             	mov    %eax,(%esp)
8010390d:	e8 a7 f6 ff ff       	call   80102fb9 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103912:	90                   	nop
80103913:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103916:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
8010391c:	85 c0                	test   %eax,%eax
8010391e:	74 f3                	je     80103913 <startothers+0x93>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103920:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103927:	a1 20 40 11 80       	mov    0x80114020,%eax
8010392c:	89 c2                	mov    %eax,%edx
8010392e:	89 d0                	mov    %edx,%eax
80103930:	c1 e0 02             	shl    $0x2,%eax
80103933:	01 d0                	add    %edx,%eax
80103935:	01 c0                	add    %eax,%eax
80103937:	01 d0                	add    %edx,%eax
80103939:	c1 e0 04             	shl    $0x4,%eax
8010393c:	05 a0 3a 11 80       	add    $0x80113aa0,%eax
80103941:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103944:	0f 87 68 ff ff ff    	ja     801038b2 <startothers+0x32>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
8010394a:	c9                   	leave  
8010394b:	c3                   	ret    

8010394c <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010394c:	55                   	push   %ebp
8010394d:	89 e5                	mov    %esp,%ebp
8010394f:	83 ec 14             	sub    $0x14,%esp
80103952:	8b 45 08             	mov    0x8(%ebp),%eax
80103955:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103959:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010395c:	89 c2                	mov    %eax,%edx
8010395e:	ec                   	in     (%dx),%al
8010395f:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103962:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80103965:	c9                   	leave  
80103966:	c3                   	ret    

80103967 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103967:	55                   	push   %ebp
80103968:	89 e5                	mov    %esp,%ebp
8010396a:	83 ec 08             	sub    $0x8,%esp
8010396d:	8b 45 08             	mov    0x8(%ebp),%eax
80103970:	8b 55 0c             	mov    0xc(%ebp),%edx
80103973:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103977:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010397a:	8a 45 f8             	mov    -0x8(%ebp),%al
8010397d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103980:	ee                   	out    %al,(%dx)
}
80103981:	c9                   	leave  
80103982:	c3                   	ret    

80103983 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80103983:	55                   	push   %ebp
80103984:	89 e5                	mov    %esp,%ebp
80103986:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
80103989:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103990:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103997:	eb 13                	jmp    801039ac <sum+0x29>
    sum += addr[i];
80103999:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010399c:	8b 45 08             	mov    0x8(%ebp),%eax
8010399f:	01 d0                	add    %edx,%eax
801039a1:	8a 00                	mov    (%eax),%al
801039a3:	0f b6 c0             	movzbl %al,%eax
801039a6:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
801039a9:	ff 45 fc             	incl   -0x4(%ebp)
801039ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
801039af:	3b 45 0c             	cmp    0xc(%ebp),%eax
801039b2:	7c e5                	jl     80103999 <sum+0x16>
    sum += addr[i];
  return sum;
801039b4:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801039b7:	c9                   	leave  
801039b8:	c3                   	ret    

801039b9 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
801039b9:	55                   	push   %ebp
801039ba:	89 e5                	mov    %esp,%ebp
801039bc:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
801039bf:	8b 45 08             	mov    0x8(%ebp),%eax
801039c2:	05 00 00 00 80       	add    $0x80000000,%eax
801039c7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
801039ca:	8b 55 0c             	mov    0xc(%ebp),%edx
801039cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039d0:	01 d0                	add    %edx,%eax
801039d2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
801039d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801039db:	eb 3f                	jmp    80103a1c <mpsearch1+0x63>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801039dd:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801039e4:	00 
801039e5:	c7 44 24 04 84 8a 10 	movl   $0x80108a84,0x4(%esp)
801039ec:	80 
801039ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039f0:	89 04 24             	mov    %eax,(%esp)
801039f3:	e8 ad 16 00 00       	call   801050a5 <memcmp>
801039f8:	85 c0                	test   %eax,%eax
801039fa:	75 1c                	jne    80103a18 <mpsearch1+0x5f>
801039fc:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103a03:	00 
80103a04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a07:	89 04 24             	mov    %eax,(%esp)
80103a0a:	e8 74 ff ff ff       	call   80103983 <sum>
80103a0f:	84 c0                	test   %al,%al
80103a11:	75 05                	jne    80103a18 <mpsearch1+0x5f>
      return (struct mp*)p;
80103a13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a16:	eb 11                	jmp    80103a29 <mpsearch1+0x70>
{
  uchar *e, *p, *addr;

  addr = P2V(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103a18:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103a1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a1f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103a22:	72 b9                	jb     801039dd <mpsearch1+0x24>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103a24:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103a29:	c9                   	leave  
80103a2a:	c3                   	ret    

80103a2b <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103a2b:	55                   	push   %ebp
80103a2c:	89 e5                	mov    %esp,%ebp
80103a2e:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103a31:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103a38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a3b:	83 c0 0f             	add    $0xf,%eax
80103a3e:	8a 00                	mov    (%eax),%al
80103a40:	0f b6 c0             	movzbl %al,%eax
80103a43:	c1 e0 08             	shl    $0x8,%eax
80103a46:	89 c2                	mov    %eax,%edx
80103a48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a4b:	83 c0 0e             	add    $0xe,%eax
80103a4e:	8a 00                	mov    (%eax),%al
80103a50:	0f b6 c0             	movzbl %al,%eax
80103a53:	09 d0                	or     %edx,%eax
80103a55:	c1 e0 04             	shl    $0x4,%eax
80103a58:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103a5b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103a5f:	74 21                	je     80103a82 <mpsearch+0x57>
    if((mp = mpsearch1(p, 1024)))
80103a61:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103a68:	00 
80103a69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a6c:	89 04 24             	mov    %eax,(%esp)
80103a6f:	e8 45 ff ff ff       	call   801039b9 <mpsearch1>
80103a74:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103a77:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103a7b:	74 4e                	je     80103acb <mpsearch+0xa0>
      return mp;
80103a7d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103a80:	eb 5d                	jmp    80103adf <mpsearch+0xb4>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103a82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a85:	83 c0 14             	add    $0x14,%eax
80103a88:	8a 00                	mov    (%eax),%al
80103a8a:	0f b6 c0             	movzbl %al,%eax
80103a8d:	c1 e0 08             	shl    $0x8,%eax
80103a90:	89 c2                	mov    %eax,%edx
80103a92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a95:	83 c0 13             	add    $0x13,%eax
80103a98:	8a 00                	mov    (%eax),%al
80103a9a:	0f b6 c0             	movzbl %al,%eax
80103a9d:	09 d0                	or     %edx,%eax
80103a9f:	c1 e0 0a             	shl    $0xa,%eax
80103aa2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103aa5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103aa8:	2d 00 04 00 00       	sub    $0x400,%eax
80103aad:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103ab4:	00 
80103ab5:	89 04 24             	mov    %eax,(%esp)
80103ab8:	e8 fc fe ff ff       	call   801039b9 <mpsearch1>
80103abd:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103ac0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103ac4:	74 05                	je     80103acb <mpsearch+0xa0>
      return mp;
80103ac6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ac9:	eb 14                	jmp    80103adf <mpsearch+0xb4>
  }
  return mpsearch1(0xF0000, 0x10000);
80103acb:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103ad2:	00 
80103ad3:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103ada:	e8 da fe ff ff       	call   801039b9 <mpsearch1>
}
80103adf:	c9                   	leave  
80103ae0:	c3                   	ret    

80103ae1 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103ae1:	55                   	push   %ebp
80103ae2:	89 e5                	mov    %esp,%ebp
80103ae4:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103ae7:	e8 3f ff ff ff       	call   80103a2b <mpsearch>
80103aec:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103aef:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103af3:	74 0a                	je     80103aff <mpconfig+0x1e>
80103af5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103af8:	8b 40 04             	mov    0x4(%eax),%eax
80103afb:	85 c0                	test   %eax,%eax
80103afd:	75 07                	jne    80103b06 <mpconfig+0x25>
    return 0;
80103aff:	b8 00 00 00 00       	mov    $0x0,%eax
80103b04:	eb 7d                	jmp    80103b83 <mpconfig+0xa2>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103b06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b09:	8b 40 04             	mov    0x4(%eax),%eax
80103b0c:	05 00 00 00 80       	add    $0x80000000,%eax
80103b11:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103b14:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103b1b:	00 
80103b1c:	c7 44 24 04 89 8a 10 	movl   $0x80108a89,0x4(%esp)
80103b23:	80 
80103b24:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b27:	89 04 24             	mov    %eax,(%esp)
80103b2a:	e8 76 15 00 00       	call   801050a5 <memcmp>
80103b2f:	85 c0                	test   %eax,%eax
80103b31:	74 07                	je     80103b3a <mpconfig+0x59>
    return 0;
80103b33:	b8 00 00 00 00       	mov    $0x0,%eax
80103b38:	eb 49                	jmp    80103b83 <mpconfig+0xa2>
  if(conf->version != 1 && conf->version != 4)
80103b3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b3d:	8a 40 06             	mov    0x6(%eax),%al
80103b40:	3c 01                	cmp    $0x1,%al
80103b42:	74 11                	je     80103b55 <mpconfig+0x74>
80103b44:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b47:	8a 40 06             	mov    0x6(%eax),%al
80103b4a:	3c 04                	cmp    $0x4,%al
80103b4c:	74 07                	je     80103b55 <mpconfig+0x74>
    return 0;
80103b4e:	b8 00 00 00 00       	mov    $0x0,%eax
80103b53:	eb 2e                	jmp    80103b83 <mpconfig+0xa2>
  if(sum((uchar*)conf, conf->length) != 0)
80103b55:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b58:	8b 40 04             	mov    0x4(%eax),%eax
80103b5b:	0f b7 c0             	movzwl %ax,%eax
80103b5e:	89 44 24 04          	mov    %eax,0x4(%esp)
80103b62:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b65:	89 04 24             	mov    %eax,(%esp)
80103b68:	e8 16 fe ff ff       	call   80103983 <sum>
80103b6d:	84 c0                	test   %al,%al
80103b6f:	74 07                	je     80103b78 <mpconfig+0x97>
    return 0;
80103b71:	b8 00 00 00 00       	mov    $0x0,%eax
80103b76:	eb 0b                	jmp    80103b83 <mpconfig+0xa2>
  *pmp = mp;
80103b78:	8b 45 08             	mov    0x8(%ebp),%eax
80103b7b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b7e:	89 10                	mov    %edx,(%eax)
  return conf;
80103b80:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103b83:	c9                   	leave  
80103b84:	c3                   	ret    

80103b85 <mpinit>:

void
mpinit(void)
{
80103b85:	55                   	push   %ebp
80103b86:	89 e5                	mov    %esp,%ebp
80103b88:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103b8b:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103b8e:	89 04 24             	mov    %eax,(%esp)
80103b91:	e8 4b ff ff ff       	call   80103ae1 <mpconfig>
80103b96:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103b99:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103b9d:	75 0c                	jne    80103bab <mpinit+0x26>
    panic("Expect to run on an SMP");
80103b9f:	c7 04 24 8e 8a 10 80 	movl   $0x80108a8e,(%esp)
80103ba6:	e8 a9 c9 ff ff       	call   80100554 <panic>
  ismp = 1;
80103bab:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  lapic = (uint*)conf->lapicaddr;
80103bb2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103bb5:	8b 40 24             	mov    0x24(%eax),%eax
80103bb8:	a3 9c 39 11 80       	mov    %eax,0x8011399c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103bbd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103bc0:	83 c0 2c             	add    $0x2c,%eax
80103bc3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103bc6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103bc9:	8b 40 04             	mov    0x4(%eax),%eax
80103bcc:	0f b7 d0             	movzwl %ax,%edx
80103bcf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103bd2:	01 d0                	add    %edx,%eax
80103bd4:	89 45 e8             	mov    %eax,-0x18(%ebp)
80103bd7:	eb 7d                	jmp    80103c56 <mpinit+0xd1>
    switch(*p){
80103bd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bdc:	8a 00                	mov    (%eax),%al
80103bde:	0f b6 c0             	movzbl %al,%eax
80103be1:	83 f8 04             	cmp    $0x4,%eax
80103be4:	77 68                	ja     80103c4e <mpinit+0xc9>
80103be6:	8b 04 85 c8 8a 10 80 	mov    -0x7fef7538(,%eax,4),%eax
80103bed:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103bef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bf2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(ncpu < NCPU) {
80103bf5:	a1 20 40 11 80       	mov    0x80114020,%eax
80103bfa:	83 f8 07             	cmp    $0x7,%eax
80103bfd:	7f 2c                	jg     80103c2b <mpinit+0xa6>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103bff:	8b 15 20 40 11 80    	mov    0x80114020,%edx
80103c05:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103c08:	8a 48 01             	mov    0x1(%eax),%cl
80103c0b:	89 d0                	mov    %edx,%eax
80103c0d:	c1 e0 02             	shl    $0x2,%eax
80103c10:	01 d0                	add    %edx,%eax
80103c12:	01 c0                	add    %eax,%eax
80103c14:	01 d0                	add    %edx,%eax
80103c16:	c1 e0 04             	shl    $0x4,%eax
80103c19:	05 a0 3a 11 80       	add    $0x80113aa0,%eax
80103c1e:	88 08                	mov    %cl,(%eax)
        ncpu++;
80103c20:	a1 20 40 11 80       	mov    0x80114020,%eax
80103c25:	40                   	inc    %eax
80103c26:	a3 20 40 11 80       	mov    %eax,0x80114020
      }
      p += sizeof(struct mpproc);
80103c2b:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103c2f:	eb 25                	jmp    80103c56 <mpinit+0xd1>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103c31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c34:	89 45 e0             	mov    %eax,-0x20(%ebp)
      ioapicid = ioapic->apicno;
80103c37:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103c3a:	8a 40 01             	mov    0x1(%eax),%al
80103c3d:	a2 80 3a 11 80       	mov    %al,0x80113a80
      p += sizeof(struct mpioapic);
80103c42:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103c46:	eb 0e                	jmp    80103c56 <mpinit+0xd1>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103c48:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103c4c:	eb 08                	jmp    80103c56 <mpinit+0xd1>
    default:
      ismp = 0;
80103c4e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      break;
80103c55:	90                   	nop

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103c56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c59:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80103c5c:	0f 82 77 ff ff ff    	jb     80103bd9 <mpinit+0x54>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
80103c62:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103c66:	75 0c                	jne    80103c74 <mpinit+0xef>
    panic("Didn't find a suitable machine");
80103c68:	c7 04 24 a8 8a 10 80 	movl   $0x80108aa8,(%esp)
80103c6f:	e8 e0 c8 ff ff       	call   80100554 <panic>

  if(mp->imcrp){
80103c74:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103c77:	8a 40 0c             	mov    0xc(%eax),%al
80103c7a:	84 c0                	test   %al,%al
80103c7c:	74 36                	je     80103cb4 <mpinit+0x12f>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103c7e:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103c85:	00 
80103c86:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103c8d:	e8 d5 fc ff ff       	call   80103967 <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103c92:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103c99:	e8 ae fc ff ff       	call   8010394c <inb>
80103c9e:	83 c8 01             	or     $0x1,%eax
80103ca1:	0f b6 c0             	movzbl %al,%eax
80103ca4:	89 44 24 04          	mov    %eax,0x4(%esp)
80103ca8:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103caf:	e8 b3 fc ff ff       	call   80103967 <outb>
  }
}
80103cb4:	c9                   	leave  
80103cb5:	c3                   	ret    
	...

80103cb8 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103cb8:	55                   	push   %ebp
80103cb9:	89 e5                	mov    %esp,%ebp
80103cbb:	83 ec 08             	sub    $0x8,%esp
80103cbe:	8b 45 08             	mov    0x8(%ebp),%eax
80103cc1:	8b 55 0c             	mov    0xc(%ebp),%edx
80103cc4:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103cc8:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103ccb:	8a 45 f8             	mov    -0x8(%ebp),%al
80103cce:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103cd1:	ee                   	out    %al,(%dx)
}
80103cd2:	c9                   	leave  
80103cd3:	c3                   	ret    

80103cd4 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103cd4:	55                   	push   %ebp
80103cd5:	89 e5                	mov    %esp,%ebp
80103cd7:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103cda:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103ce1:	00 
80103ce2:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103ce9:	e8 ca ff ff ff       	call   80103cb8 <outb>
  outb(IO_PIC2+1, 0xFF);
80103cee:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103cf5:	00 
80103cf6:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103cfd:	e8 b6 ff ff ff       	call   80103cb8 <outb>
}
80103d02:	c9                   	leave  
80103d03:	c3                   	ret    

80103d04 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103d04:	55                   	push   %ebp
80103d05:	89 e5                	mov    %esp,%ebp
80103d07:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103d0a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103d11:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d14:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103d1a:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d1d:	8b 10                	mov    (%eax),%edx
80103d1f:	8b 45 08             	mov    0x8(%ebp),%eax
80103d22:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103d24:	e8 d3 d2 ff ff       	call   80100ffc <filealloc>
80103d29:	8b 55 08             	mov    0x8(%ebp),%edx
80103d2c:	89 02                	mov    %eax,(%edx)
80103d2e:	8b 45 08             	mov    0x8(%ebp),%eax
80103d31:	8b 00                	mov    (%eax),%eax
80103d33:	85 c0                	test   %eax,%eax
80103d35:	0f 84 c8 00 00 00    	je     80103e03 <pipealloc+0xff>
80103d3b:	e8 bc d2 ff ff       	call   80100ffc <filealloc>
80103d40:	8b 55 0c             	mov    0xc(%ebp),%edx
80103d43:	89 02                	mov    %eax,(%edx)
80103d45:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d48:	8b 00                	mov    (%eax),%eax
80103d4a:	85 c0                	test   %eax,%eax
80103d4c:	0f 84 b1 00 00 00    	je     80103e03 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103d52:	e8 98 ee ff ff       	call   80102bef <kalloc>
80103d57:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d5a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d5e:	75 05                	jne    80103d65 <pipealloc+0x61>
    goto bad;
80103d60:	e9 9e 00 00 00       	jmp    80103e03 <pipealloc+0xff>
  p->readopen = 1;
80103d65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d68:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103d6f:	00 00 00 
  p->writeopen = 1;
80103d72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d75:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103d7c:	00 00 00 
  p->nwrite = 0;
80103d7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d82:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103d89:	00 00 00 
  p->nread = 0;
80103d8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d8f:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103d96:	00 00 00 
  initlock(&p->lock, "pipe");
80103d99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d9c:	c7 44 24 04 dc 8a 10 	movl   $0x80108adc,0x4(%esp)
80103da3:	80 
80103da4:	89 04 24             	mov    %eax,(%esp)
80103da7:	e8 fe 0f 00 00       	call   80104daa <initlock>
  (*f0)->type = FD_PIPE;
80103dac:	8b 45 08             	mov    0x8(%ebp),%eax
80103daf:	8b 00                	mov    (%eax),%eax
80103db1:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103db7:	8b 45 08             	mov    0x8(%ebp),%eax
80103dba:	8b 00                	mov    (%eax),%eax
80103dbc:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103dc0:	8b 45 08             	mov    0x8(%ebp),%eax
80103dc3:	8b 00                	mov    (%eax),%eax
80103dc5:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103dc9:	8b 45 08             	mov    0x8(%ebp),%eax
80103dcc:	8b 00                	mov    (%eax),%eax
80103dce:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103dd1:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103dd4:	8b 45 0c             	mov    0xc(%ebp),%eax
80103dd7:	8b 00                	mov    (%eax),%eax
80103dd9:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103ddf:	8b 45 0c             	mov    0xc(%ebp),%eax
80103de2:	8b 00                	mov    (%eax),%eax
80103de4:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103de8:	8b 45 0c             	mov    0xc(%ebp),%eax
80103deb:	8b 00                	mov    (%eax),%eax
80103ded:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103df1:	8b 45 0c             	mov    0xc(%ebp),%eax
80103df4:	8b 00                	mov    (%eax),%eax
80103df6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103df9:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103dfc:	b8 00 00 00 00       	mov    $0x0,%eax
80103e01:	eb 42                	jmp    80103e45 <pipealloc+0x141>

//PAGEBREAK: 20
 bad:
  if(p)
80103e03:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103e07:	74 0b                	je     80103e14 <pipealloc+0x110>
    kfree((char*)p);
80103e09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e0c:	89 04 24             	mov    %eax,(%esp)
80103e0f:	e8 45 ed ff ff       	call   80102b59 <kfree>
  if(*f0)
80103e14:	8b 45 08             	mov    0x8(%ebp),%eax
80103e17:	8b 00                	mov    (%eax),%eax
80103e19:	85 c0                	test   %eax,%eax
80103e1b:	74 0d                	je     80103e2a <pipealloc+0x126>
    fileclose(*f0);
80103e1d:	8b 45 08             	mov    0x8(%ebp),%eax
80103e20:	8b 00                	mov    (%eax),%eax
80103e22:	89 04 24             	mov    %eax,(%esp)
80103e25:	e8 7a d2 ff ff       	call   801010a4 <fileclose>
  if(*f1)
80103e2a:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e2d:	8b 00                	mov    (%eax),%eax
80103e2f:	85 c0                	test   %eax,%eax
80103e31:	74 0d                	je     80103e40 <pipealloc+0x13c>
    fileclose(*f1);
80103e33:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e36:	8b 00                	mov    (%eax),%eax
80103e38:	89 04 24             	mov    %eax,(%esp)
80103e3b:	e8 64 d2 ff ff       	call   801010a4 <fileclose>
  return -1;
80103e40:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103e45:	c9                   	leave  
80103e46:	c3                   	ret    

80103e47 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103e47:	55                   	push   %ebp
80103e48:	89 e5                	mov    %esp,%ebp
80103e4a:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
80103e4d:	8b 45 08             	mov    0x8(%ebp),%eax
80103e50:	89 04 24             	mov    %eax,(%esp)
80103e53:	e8 73 0f 00 00       	call   80104dcb <acquire>
  if(writable){
80103e58:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103e5c:	74 1f                	je     80103e7d <pipeclose+0x36>
    p->writeopen = 0;
80103e5e:	8b 45 08             	mov    0x8(%ebp),%eax
80103e61:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103e68:	00 00 00 
    wakeup(&p->nread);
80103e6b:	8b 45 08             	mov    0x8(%ebp),%eax
80103e6e:	05 34 02 00 00       	add    $0x234,%eax
80103e73:	89 04 24             	mov    %eax,(%esp)
80103e76:	e8 56 0c 00 00       	call   80104ad1 <wakeup>
80103e7b:	eb 1d                	jmp    80103e9a <pipeclose+0x53>
  } else {
    p->readopen = 0;
80103e7d:	8b 45 08             	mov    0x8(%ebp),%eax
80103e80:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103e87:	00 00 00 
    wakeup(&p->nwrite);
80103e8a:	8b 45 08             	mov    0x8(%ebp),%eax
80103e8d:	05 38 02 00 00       	add    $0x238,%eax
80103e92:	89 04 24             	mov    %eax,(%esp)
80103e95:	e8 37 0c 00 00       	call   80104ad1 <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103e9a:	8b 45 08             	mov    0x8(%ebp),%eax
80103e9d:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103ea3:	85 c0                	test   %eax,%eax
80103ea5:	75 25                	jne    80103ecc <pipeclose+0x85>
80103ea7:	8b 45 08             	mov    0x8(%ebp),%eax
80103eaa:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103eb0:	85 c0                	test   %eax,%eax
80103eb2:	75 18                	jne    80103ecc <pipeclose+0x85>
    release(&p->lock);
80103eb4:	8b 45 08             	mov    0x8(%ebp),%eax
80103eb7:	89 04 24             	mov    %eax,(%esp)
80103eba:	e8 76 0f 00 00       	call   80104e35 <release>
    kfree((char*)p);
80103ebf:	8b 45 08             	mov    0x8(%ebp),%eax
80103ec2:	89 04 24             	mov    %eax,(%esp)
80103ec5:	e8 8f ec ff ff       	call   80102b59 <kfree>
80103eca:	eb 0b                	jmp    80103ed7 <pipeclose+0x90>
  } else
    release(&p->lock);
80103ecc:	8b 45 08             	mov    0x8(%ebp),%eax
80103ecf:	89 04 24             	mov    %eax,(%esp)
80103ed2:	e8 5e 0f 00 00       	call   80104e35 <release>
}
80103ed7:	c9                   	leave  
80103ed8:	c3                   	ret    

80103ed9 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103ed9:	55                   	push   %ebp
80103eda:	89 e5                	mov    %esp,%ebp
80103edc:	83 ec 28             	sub    $0x28,%esp
  int i;

  acquire(&p->lock);
80103edf:	8b 45 08             	mov    0x8(%ebp),%eax
80103ee2:	89 04 24             	mov    %eax,(%esp)
80103ee5:	e8 e1 0e 00 00       	call   80104dcb <acquire>
  for(i = 0; i < n; i++){
80103eea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103ef1:	e9 a3 00 00 00       	jmp    80103f99 <pipewrite+0xc0>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103ef6:	eb 56                	jmp    80103f4e <pipewrite+0x75>
      if(p->readopen == 0 || myproc()->killed){
80103ef8:	8b 45 08             	mov    0x8(%ebp),%eax
80103efb:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103f01:	85 c0                	test   %eax,%eax
80103f03:	74 0c                	je     80103f11 <pipewrite+0x38>
80103f05:	e8 a5 02 00 00       	call   801041af <myproc>
80103f0a:	8b 40 24             	mov    0x24(%eax),%eax
80103f0d:	85 c0                	test   %eax,%eax
80103f0f:	74 15                	je     80103f26 <pipewrite+0x4d>
        release(&p->lock);
80103f11:	8b 45 08             	mov    0x8(%ebp),%eax
80103f14:	89 04 24             	mov    %eax,(%esp)
80103f17:	e8 19 0f 00 00       	call   80104e35 <release>
        return -1;
80103f1c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f21:	e9 9d 00 00 00       	jmp    80103fc3 <pipewrite+0xea>
      }
      wakeup(&p->nread);
80103f26:	8b 45 08             	mov    0x8(%ebp),%eax
80103f29:	05 34 02 00 00       	add    $0x234,%eax
80103f2e:	89 04 24             	mov    %eax,(%esp)
80103f31:	e8 9b 0b 00 00       	call   80104ad1 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80103f36:	8b 45 08             	mov    0x8(%ebp),%eax
80103f39:	8b 55 08             	mov    0x8(%ebp),%edx
80103f3c:	81 c2 38 02 00 00    	add    $0x238,%edx
80103f42:	89 44 24 04          	mov    %eax,0x4(%esp)
80103f46:	89 14 24             	mov    %edx,(%esp)
80103f49:	e8 af 0a 00 00       	call   801049fd <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103f4e:	8b 45 08             	mov    0x8(%ebp),%eax
80103f51:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80103f57:	8b 45 08             	mov    0x8(%ebp),%eax
80103f5a:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103f60:	05 00 02 00 00       	add    $0x200,%eax
80103f65:	39 c2                	cmp    %eax,%edx
80103f67:	74 8f                	je     80103ef8 <pipewrite+0x1f>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103f69:	8b 45 08             	mov    0x8(%ebp),%eax
80103f6c:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103f72:	8d 48 01             	lea    0x1(%eax),%ecx
80103f75:	8b 55 08             	mov    0x8(%ebp),%edx
80103f78:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80103f7e:	25 ff 01 00 00       	and    $0x1ff,%eax
80103f83:	89 c1                	mov    %eax,%ecx
80103f85:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103f88:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f8b:	01 d0                	add    %edx,%eax
80103f8d:	8a 10                	mov    (%eax),%dl
80103f8f:	8b 45 08             	mov    0x8(%ebp),%eax
80103f92:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80103f96:	ff 45 f4             	incl   -0xc(%ebp)
80103f99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f9c:	3b 45 10             	cmp    0x10(%ebp),%eax
80103f9f:	0f 8c 51 ff ff ff    	jl     80103ef6 <pipewrite+0x1d>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103fa5:	8b 45 08             	mov    0x8(%ebp),%eax
80103fa8:	05 34 02 00 00       	add    $0x234,%eax
80103fad:	89 04 24             	mov    %eax,(%esp)
80103fb0:	e8 1c 0b 00 00       	call   80104ad1 <wakeup>
  release(&p->lock);
80103fb5:	8b 45 08             	mov    0x8(%ebp),%eax
80103fb8:	89 04 24             	mov    %eax,(%esp)
80103fbb:	e8 75 0e 00 00       	call   80104e35 <release>
  return n;
80103fc0:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103fc3:	c9                   	leave  
80103fc4:	c3                   	ret    

80103fc5 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80103fc5:	55                   	push   %ebp
80103fc6:	89 e5                	mov    %esp,%ebp
80103fc8:	53                   	push   %ebx
80103fc9:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80103fcc:	8b 45 08             	mov    0x8(%ebp),%eax
80103fcf:	89 04 24             	mov    %eax,(%esp)
80103fd2:	e8 f4 0d 00 00       	call   80104dcb <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103fd7:	eb 39                	jmp    80104012 <piperead+0x4d>
    if(myproc()->killed){
80103fd9:	e8 d1 01 00 00       	call   801041af <myproc>
80103fde:	8b 40 24             	mov    0x24(%eax),%eax
80103fe1:	85 c0                	test   %eax,%eax
80103fe3:	74 15                	je     80103ffa <piperead+0x35>
      release(&p->lock);
80103fe5:	8b 45 08             	mov    0x8(%ebp),%eax
80103fe8:	89 04 24             	mov    %eax,(%esp)
80103feb:	e8 45 0e 00 00       	call   80104e35 <release>
      return -1;
80103ff0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103ff5:	e9 b3 00 00 00       	jmp    801040ad <piperead+0xe8>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103ffa:	8b 45 08             	mov    0x8(%ebp),%eax
80103ffd:	8b 55 08             	mov    0x8(%ebp),%edx
80104000:	81 c2 34 02 00 00    	add    $0x234,%edx
80104006:	89 44 24 04          	mov    %eax,0x4(%esp)
8010400a:	89 14 24             	mov    %edx,(%esp)
8010400d:	e8 eb 09 00 00       	call   801049fd <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104012:	8b 45 08             	mov    0x8(%ebp),%eax
80104015:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010401b:	8b 45 08             	mov    0x8(%ebp),%eax
8010401e:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104024:	39 c2                	cmp    %eax,%edx
80104026:	75 0d                	jne    80104035 <piperead+0x70>
80104028:	8b 45 08             	mov    0x8(%ebp),%eax
8010402b:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104031:	85 c0                	test   %eax,%eax
80104033:	75 a4                	jne    80103fd9 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104035:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010403c:	eb 49                	jmp    80104087 <piperead+0xc2>
    if(p->nread == p->nwrite)
8010403e:	8b 45 08             	mov    0x8(%ebp),%eax
80104041:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104047:	8b 45 08             	mov    0x8(%ebp),%eax
8010404a:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104050:	39 c2                	cmp    %eax,%edx
80104052:	75 02                	jne    80104056 <piperead+0x91>
      break;
80104054:	eb 39                	jmp    8010408f <piperead+0xca>
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104056:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104059:	8b 45 0c             	mov    0xc(%ebp),%eax
8010405c:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010405f:	8b 45 08             	mov    0x8(%ebp),%eax
80104062:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104068:	8d 48 01             	lea    0x1(%eax),%ecx
8010406b:	8b 55 08             	mov    0x8(%ebp),%edx
8010406e:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104074:	25 ff 01 00 00       	and    $0x1ff,%eax
80104079:	89 c2                	mov    %eax,%edx
8010407b:	8b 45 08             	mov    0x8(%ebp),%eax
8010407e:	8a 44 10 34          	mov    0x34(%eax,%edx,1),%al
80104082:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104084:	ff 45 f4             	incl   -0xc(%ebp)
80104087:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010408a:	3b 45 10             	cmp    0x10(%ebp),%eax
8010408d:	7c af                	jl     8010403e <piperead+0x79>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
8010408f:	8b 45 08             	mov    0x8(%ebp),%eax
80104092:	05 38 02 00 00       	add    $0x238,%eax
80104097:	89 04 24             	mov    %eax,(%esp)
8010409a:	e8 32 0a 00 00       	call   80104ad1 <wakeup>
  release(&p->lock);
8010409f:	8b 45 08             	mov    0x8(%ebp),%eax
801040a2:	89 04 24             	mov    %eax,(%esp)
801040a5:	e8 8b 0d 00 00       	call   80104e35 <release>
  return i;
801040aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801040ad:	83 c4 24             	add    $0x24,%esp
801040b0:	5b                   	pop    %ebx
801040b1:	5d                   	pop    %ebp
801040b2:	c3                   	ret    
	...

801040b4 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801040b4:	55                   	push   %ebp
801040b5:	89 e5                	mov    %esp,%ebp
801040b7:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801040ba:	9c                   	pushf  
801040bb:	58                   	pop    %eax
801040bc:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801040bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801040c2:	c9                   	leave  
801040c3:	c3                   	ret    

801040c4 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
801040c4:	55                   	push   %ebp
801040c5:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801040c7:	fb                   	sti    
}
801040c8:	5d                   	pop    %ebp
801040c9:	c3                   	ret    

801040ca <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
801040ca:	55                   	push   %ebp
801040cb:	89 e5                	mov    %esp,%ebp
801040cd:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
801040d0:	c7 44 24 04 e4 8a 10 	movl   $0x80108ae4,0x4(%esp)
801040d7:	80 
801040d8:	c7 04 24 40 40 11 80 	movl   $0x80114040,(%esp)
801040df:	e8 c6 0c 00 00       	call   80104daa <initlock>
}
801040e4:	c9                   	leave  
801040e5:	c3                   	ret    

801040e6 <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
801040e6:	55                   	push   %ebp
801040e7:	89 e5                	mov    %esp,%ebp
801040e9:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
801040ec:	e8 3a 00 00 00       	call   8010412b <mycpu>
801040f1:	89 c2                	mov    %eax,%edx
801040f3:	b8 a0 3a 11 80       	mov    $0x80113aa0,%eax
801040f8:	29 c2                	sub    %eax,%edx
801040fa:	89 d0                	mov    %edx,%eax
801040fc:	c1 f8 04             	sar    $0x4,%eax
801040ff:	89 c1                	mov    %eax,%ecx
80104101:	89 ca                	mov    %ecx,%edx
80104103:	c1 e2 03             	shl    $0x3,%edx
80104106:	01 ca                	add    %ecx,%edx
80104108:	89 d0                	mov    %edx,%eax
8010410a:	c1 e0 05             	shl    $0x5,%eax
8010410d:	29 d0                	sub    %edx,%eax
8010410f:	c1 e0 02             	shl    $0x2,%eax
80104112:	01 c8                	add    %ecx,%eax
80104114:	c1 e0 03             	shl    $0x3,%eax
80104117:	01 c8                	add    %ecx,%eax
80104119:	89 c2                	mov    %eax,%edx
8010411b:	c1 e2 0f             	shl    $0xf,%edx
8010411e:	29 c2                	sub    %eax,%edx
80104120:	c1 e2 02             	shl    $0x2,%edx
80104123:	01 ca                	add    %ecx,%edx
80104125:	89 d0                	mov    %edx,%eax
80104127:	f7 d8                	neg    %eax
}
80104129:	c9                   	leave  
8010412a:	c3                   	ret    

8010412b <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
8010412b:	55                   	push   %ebp
8010412c:	89 e5                	mov    %esp,%ebp
8010412e:	83 ec 28             	sub    $0x28,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF)
80104131:	e8 7e ff ff ff       	call   801040b4 <readeflags>
80104136:	25 00 02 00 00       	and    $0x200,%eax
8010413b:	85 c0                	test   %eax,%eax
8010413d:	74 0c                	je     8010414b <mycpu+0x20>
    panic("mycpu called with interrupts enabled\n");
8010413f:	c7 04 24 ec 8a 10 80 	movl   $0x80108aec,(%esp)
80104146:	e8 09 c4 ff ff       	call   80100554 <panic>
  
  apicid = lapicid();
8010414b:	e8 1d ee ff ff       	call   80102f6d <lapicid>
80104150:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80104153:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010415a:	eb 3b                	jmp    80104197 <mycpu+0x6c>
    if (cpus[i].apicid == apicid)
8010415c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010415f:	89 d0                	mov    %edx,%eax
80104161:	c1 e0 02             	shl    $0x2,%eax
80104164:	01 d0                	add    %edx,%eax
80104166:	01 c0                	add    %eax,%eax
80104168:	01 d0                	add    %edx,%eax
8010416a:	c1 e0 04             	shl    $0x4,%eax
8010416d:	05 a0 3a 11 80       	add    $0x80113aa0,%eax
80104172:	8a 00                	mov    (%eax),%al
80104174:	0f b6 c0             	movzbl %al,%eax
80104177:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010417a:	75 18                	jne    80104194 <mycpu+0x69>
      return &cpus[i];
8010417c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010417f:	89 d0                	mov    %edx,%eax
80104181:	c1 e0 02             	shl    $0x2,%eax
80104184:	01 d0                	add    %edx,%eax
80104186:	01 c0                	add    %eax,%eax
80104188:	01 d0                	add    %edx,%eax
8010418a:	c1 e0 04             	shl    $0x4,%eax
8010418d:	05 a0 3a 11 80       	add    $0x80113aa0,%eax
80104192:	eb 19                	jmp    801041ad <mycpu+0x82>
    panic("mycpu called with interrupts enabled\n");
  
  apicid = lapicid();
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80104194:	ff 45 f4             	incl   -0xc(%ebp)
80104197:	a1 20 40 11 80       	mov    0x80114020,%eax
8010419c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010419f:	7c bb                	jl     8010415c <mycpu+0x31>
    if (cpus[i].apicid == apicid)
      return &cpus[i];
  }
  panic("unknown apicid\n");
801041a1:	c7 04 24 12 8b 10 80 	movl   $0x80108b12,(%esp)
801041a8:	e8 a7 c3 ff ff       	call   80100554 <panic>
}
801041ad:	c9                   	leave  
801041ae:	c3                   	ret    

801041af <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
801041af:	55                   	push   %ebp
801041b0:	89 e5                	mov    %esp,%ebp
801041b2:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
801041b5:	e8 70 0d 00 00       	call   80104f2a <pushcli>
  c = mycpu();
801041ba:	e8 6c ff ff ff       	call   8010412b <mycpu>
801041bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
801041c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041c5:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801041cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
801041ce:	e8 a1 0d 00 00       	call   80104f74 <popcli>
  return p;
801041d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801041d6:	c9                   	leave  
801041d7:	c3                   	ret    

801041d8 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
801041d8:	55                   	push   %ebp
801041d9:	89 e5                	mov    %esp,%ebp
801041db:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
801041de:	c7 04 24 40 40 11 80 	movl   $0x80114040,(%esp)
801041e5:	e8 e1 0b 00 00       	call   80104dcb <acquire>

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801041ea:	c7 45 f4 74 40 11 80 	movl   $0x80114074,-0xc(%ebp)
801041f1:	eb 50                	jmp    80104243 <allocproc+0x6b>
    if(p->state == UNUSED)
801041f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041f6:	8b 40 0c             	mov    0xc(%eax),%eax
801041f9:	85 c0                	test   %eax,%eax
801041fb:	75 42                	jne    8010423f <allocproc+0x67>
      goto found;
801041fd:	90                   	nop

  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
801041fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104201:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104208:	a1 00 b0 10 80       	mov    0x8010b000,%eax
8010420d:	8d 50 01             	lea    0x1(%eax),%edx
80104210:	89 15 00 b0 10 80    	mov    %edx,0x8010b000
80104216:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104219:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
8010421c:	c7 04 24 40 40 11 80 	movl   $0x80114040,(%esp)
80104223:	e8 0d 0c 00 00       	call   80104e35 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104228:	e8 c2 e9 ff ff       	call   80102bef <kalloc>
8010422d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104230:	89 42 08             	mov    %eax,0x8(%edx)
80104233:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104236:	8b 40 08             	mov    0x8(%eax),%eax
80104239:	85 c0                	test   %eax,%eax
8010423b:	75 36                	jne    80104273 <allocproc+0x9b>
8010423d:	eb 23                	jmp    80104262 <allocproc+0x8a>
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010423f:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104243:	81 7d f4 74 60 11 80 	cmpl   $0x80116074,-0xc(%ebp)
8010424a:	72 a7                	jb     801041f3 <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;

  release(&ptable.lock);
8010424c:	c7 04 24 40 40 11 80 	movl   $0x80114040,(%esp)
80104253:	e8 dd 0b 00 00       	call   80104e35 <release>
  return 0;
80104258:	b8 00 00 00 00       	mov    $0x0,%eax
8010425d:	e9 80 00 00 00       	jmp    801042e2 <allocproc+0x10a>

  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
80104262:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104265:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
8010426c:	b8 00 00 00 00       	mov    $0x0,%eax
80104271:	eb 6f                	jmp    801042e2 <allocproc+0x10a>
  }
  sp = p->kstack + KSTACKSIZE;
80104273:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104276:	8b 40 08             	mov    0x8(%eax),%eax
80104279:	05 00 10 00 00       	add    $0x1000,%eax
8010427e:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104281:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104285:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104288:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010428b:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
8010428e:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104292:	ba 9c 66 10 80       	mov    $0x8010669c,%edx
80104297:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010429a:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
8010429c:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
801042a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042a3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801042a6:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
801042a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042ac:	8b 40 1c             	mov    0x1c(%eax),%eax
801042af:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
801042b6:	00 
801042b7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801042be:	00 
801042bf:	89 04 24             	mov    %eax,(%esp)
801042c2:	e8 67 0d 00 00       	call   8010502e <memset>
  p->context->eip = (uint)forkret;
801042c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042ca:	8b 40 1c             	mov    0x1c(%eax),%eax
801042cd:	ba be 49 10 80       	mov    $0x801049be,%edx
801042d2:	89 50 10             	mov    %edx,0x10(%eax)

  p->ticks = 0;
801042d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042d8:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)

  return p;
801042df:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801042e2:	c9                   	leave  
801042e3:	c3                   	ret    

801042e4 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801042e4:	55                   	push   %ebp
801042e5:	89 e5                	mov    %esp,%ebp
801042e7:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
801042ea:	e8 e9 fe ff ff       	call   801041d8 <allocproc>
801042ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
801042f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042f5:	a3 c0 b8 10 80       	mov    %eax,0x8010b8c0
  if((p->pgdir = setupkvm()) == 0)
801042fa:	e8 f7 38 00 00       	call   80107bf6 <setupkvm>
801042ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104302:	89 42 04             	mov    %eax,0x4(%edx)
80104305:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104308:	8b 40 04             	mov    0x4(%eax),%eax
8010430b:	85 c0                	test   %eax,%eax
8010430d:	75 0c                	jne    8010431b <userinit+0x37>
    panic("userinit: out of memory?");
8010430f:	c7 04 24 22 8b 10 80 	movl   $0x80108b22,(%esp)
80104316:	e8 39 c2 ff ff       	call   80100554 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
8010431b:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104320:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104323:	8b 40 04             	mov    0x4(%eax),%eax
80104326:	89 54 24 08          	mov    %edx,0x8(%esp)
8010432a:	c7 44 24 04 00 b5 10 	movl   $0x8010b500,0x4(%esp)
80104331:	80 
80104332:	89 04 24             	mov    %eax,(%esp)
80104335:	e8 1d 3b 00 00       	call   80107e57 <inituvm>
  p->sz = PGSIZE;
8010433a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010433d:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104343:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104346:	8b 40 18             	mov    0x18(%eax),%eax
80104349:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
80104350:	00 
80104351:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104358:	00 
80104359:	89 04 24             	mov    %eax,(%esp)
8010435c:	e8 cd 0c 00 00       	call   8010502e <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104361:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104364:	8b 40 18             	mov    0x18(%eax),%eax
80104367:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
8010436d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104370:	8b 40 18             	mov    0x18(%eax),%eax
80104373:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104379:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010437c:	8b 50 18             	mov    0x18(%eax),%edx
8010437f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104382:	8b 40 18             	mov    0x18(%eax),%eax
80104385:	8b 40 2c             	mov    0x2c(%eax),%eax
80104388:	66 89 42 28          	mov    %ax,0x28(%edx)
  p->tf->ss = p->tf->ds;
8010438c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010438f:	8b 50 18             	mov    0x18(%eax),%edx
80104392:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104395:	8b 40 18             	mov    0x18(%eax),%eax
80104398:	8b 40 2c             	mov    0x2c(%eax),%eax
8010439b:	66 89 42 48          	mov    %ax,0x48(%edx)
  p->tf->eflags = FL_IF;
8010439f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043a2:	8b 40 18             	mov    0x18(%eax),%eax
801043a5:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801043ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043af:	8b 40 18             	mov    0x18(%eax),%eax
801043b2:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801043b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043bc:	8b 40 18             	mov    0x18(%eax),%eax
801043bf:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
801043c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043c9:	83 c0 6c             	add    $0x6c,%eax
801043cc:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801043d3:	00 
801043d4:	c7 44 24 04 3b 8b 10 	movl   $0x80108b3b,0x4(%esp)
801043db:	80 
801043dc:	89 04 24             	mov    %eax,(%esp)
801043df:	e8 56 0e 00 00       	call   8010523a <safestrcpy>
  p->cwd = namei("/");
801043e4:	c7 04 24 44 8b 10 80 	movl   $0x80108b44,(%esp)
801043eb:	e8 f3 e0 ff ff       	call   801024e3 <namei>
801043f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043f3:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
801043f6:	c7 04 24 40 40 11 80 	movl   $0x80114040,(%esp)
801043fd:	e8 c9 09 00 00       	call   80104dcb <acquire>

  p->state = RUNNABLE;
80104402:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104405:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
8010440c:	c7 04 24 40 40 11 80 	movl   $0x80114040,(%esp)
80104413:	e8 1d 0a 00 00       	call   80104e35 <release>
}
80104418:	c9                   	leave  
80104419:	c3                   	ret    

8010441a <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
8010441a:	55                   	push   %ebp
8010441b:	89 e5                	mov    %esp,%ebp
8010441d:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  struct proc *curproc = myproc();
80104420:	e8 8a fd ff ff       	call   801041af <myproc>
80104425:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80104428:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010442b:	8b 00                	mov    (%eax),%eax
8010442d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104430:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104434:	7e 31                	jle    80104467 <growproc+0x4d>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104436:	8b 55 08             	mov    0x8(%ebp),%edx
80104439:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010443c:	01 c2                	add    %eax,%edx
8010443e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104441:	8b 40 04             	mov    0x4(%eax),%eax
80104444:	89 54 24 08          	mov    %edx,0x8(%esp)
80104448:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010444b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010444f:	89 04 24             	mov    %eax,(%esp)
80104452:	e8 6b 3b 00 00       	call   80107fc2 <allocuvm>
80104457:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010445a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010445e:	75 3e                	jne    8010449e <growproc+0x84>
      return -1;
80104460:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104465:	eb 4f                	jmp    801044b6 <growproc+0x9c>
  } else if(n < 0){
80104467:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010446b:	79 31                	jns    8010449e <growproc+0x84>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
8010446d:	8b 55 08             	mov    0x8(%ebp),%edx
80104470:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104473:	01 c2                	add    %eax,%edx
80104475:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104478:	8b 40 04             	mov    0x4(%eax),%eax
8010447b:	89 54 24 08          	mov    %edx,0x8(%esp)
8010447f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104482:	89 54 24 04          	mov    %edx,0x4(%esp)
80104486:	89 04 24             	mov    %eax,(%esp)
80104489:	e8 4a 3c 00 00       	call   801080d8 <deallocuvm>
8010448e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104491:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104495:	75 07                	jne    8010449e <growproc+0x84>
      return -1;
80104497:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010449c:	eb 18                	jmp    801044b6 <growproc+0x9c>
  }
  curproc->sz = sz;
8010449e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044a4:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
801044a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044a9:	89 04 24             	mov    %eax,(%esp)
801044ac:	e8 1f 38 00 00       	call   80107cd0 <switchuvm>
  return 0;
801044b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801044b6:	c9                   	leave  
801044b7:	c3                   	ret    

801044b8 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
801044b8:	55                   	push   %ebp
801044b9:	89 e5                	mov    %esp,%ebp
801044bb:	57                   	push   %edi
801044bc:	56                   	push   %esi
801044bd:	53                   	push   %ebx
801044be:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
801044c1:	e8 e9 fc ff ff       	call   801041af <myproc>
801044c6:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
801044c9:	e8 0a fd ff ff       	call   801041d8 <allocproc>
801044ce:	89 45 dc             	mov    %eax,-0x24(%ebp)
801044d1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
801044d5:	75 0a                	jne    801044e1 <fork+0x29>
    return -1;
801044d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044dc:	e9 35 01 00 00       	jmp    80104616 <fork+0x15e>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
801044e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801044e4:	8b 10                	mov    (%eax),%edx
801044e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801044e9:	8b 40 04             	mov    0x4(%eax),%eax
801044ec:	89 54 24 04          	mov    %edx,0x4(%esp)
801044f0:	89 04 24             	mov    %eax,(%esp)
801044f3:	e8 80 3d 00 00       	call   80108278 <copyuvm>
801044f8:	8b 55 dc             	mov    -0x24(%ebp),%edx
801044fb:	89 42 04             	mov    %eax,0x4(%edx)
801044fe:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104501:	8b 40 04             	mov    0x4(%eax),%eax
80104504:	85 c0                	test   %eax,%eax
80104506:	75 2c                	jne    80104534 <fork+0x7c>
    kfree(np->kstack);
80104508:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010450b:	8b 40 08             	mov    0x8(%eax),%eax
8010450e:	89 04 24             	mov    %eax,(%esp)
80104511:	e8 43 e6 ff ff       	call   80102b59 <kfree>
    np->kstack = 0;
80104516:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104519:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104520:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104523:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
8010452a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010452f:	e9 e2 00 00 00       	jmp    80104616 <fork+0x15e>
  }
  np->sz = curproc->sz;
80104534:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104537:	8b 10                	mov    (%eax),%edx
80104539:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010453c:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
8010453e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104541:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104544:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80104547:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010454a:	8b 50 18             	mov    0x18(%eax),%edx
8010454d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104550:	8b 40 18             	mov    0x18(%eax),%eax
80104553:	89 c3                	mov    %eax,%ebx
80104555:	b8 13 00 00 00       	mov    $0x13,%eax
8010455a:	89 d7                	mov    %edx,%edi
8010455c:	89 de                	mov    %ebx,%esi
8010455e:	89 c1                	mov    %eax,%ecx
80104560:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104562:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104565:	8b 40 18             	mov    0x18(%eax),%eax
80104568:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
8010456f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104576:	eb 36                	jmp    801045ae <fork+0xf6>
    if(curproc->ofile[i])
80104578:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010457b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010457e:	83 c2 08             	add    $0x8,%edx
80104581:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104585:	85 c0                	test   %eax,%eax
80104587:	74 22                	je     801045ab <fork+0xf3>
      np->ofile[i] = filedup(curproc->ofile[i]);
80104589:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010458c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010458f:	83 c2 08             	add    $0x8,%edx
80104592:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104596:	89 04 24             	mov    %eax,(%esp)
80104599:	e8 be ca ff ff       	call   8010105c <filedup>
8010459e:	8b 55 dc             	mov    -0x24(%ebp),%edx
801045a1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801045a4:	83 c1 08             	add    $0x8,%ecx
801045a7:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *curproc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
801045ab:	ff 45 e4             	incl   -0x1c(%ebp)
801045ae:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
801045b2:	7e c4                	jle    80104578 <fork+0xc0>
    if(curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);
801045b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801045b7:	8b 40 68             	mov    0x68(%eax),%eax
801045ba:	89 04 24             	mov    %eax,(%esp)
801045bd:	e8 ca d3 ff ff       	call   8010198c <idup>
801045c2:	8b 55 dc             	mov    -0x24(%ebp),%edx
801045c5:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
801045c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801045cb:	8d 50 6c             	lea    0x6c(%eax),%edx
801045ce:	8b 45 dc             	mov    -0x24(%ebp),%eax
801045d1:	83 c0 6c             	add    $0x6c,%eax
801045d4:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801045db:	00 
801045dc:	89 54 24 04          	mov    %edx,0x4(%esp)
801045e0:	89 04 24             	mov    %eax,(%esp)
801045e3:	e8 52 0c 00 00       	call   8010523a <safestrcpy>

  pid = np->pid;
801045e8:	8b 45 dc             	mov    -0x24(%ebp),%eax
801045eb:	8b 40 10             	mov    0x10(%eax),%eax
801045ee:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
801045f1:	c7 04 24 40 40 11 80 	movl   $0x80114040,(%esp)
801045f8:	e8 ce 07 00 00       	call   80104dcb <acquire>

  np->state = RUNNABLE;
801045fd:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104600:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104607:	c7 04 24 40 40 11 80 	movl   $0x80114040,(%esp)
8010460e:	e8 22 08 00 00       	call   80104e35 <release>

  return pid;
80104613:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80104616:	83 c4 2c             	add    $0x2c,%esp
80104619:	5b                   	pop    %ebx
8010461a:	5e                   	pop    %esi
8010461b:	5f                   	pop    %edi
8010461c:	5d                   	pop    %ebp
8010461d:	c3                   	ret    

8010461e <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
8010461e:	55                   	push   %ebp
8010461f:	89 e5                	mov    %esp,%ebp
80104621:	83 ec 28             	sub    $0x28,%esp
  struct proc *curproc = myproc();
80104624:	e8 86 fb ff ff       	call   801041af <myproc>
80104629:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
8010462c:	a1 c0 b8 10 80       	mov    0x8010b8c0,%eax
80104631:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104634:	75 0c                	jne    80104642 <exit+0x24>
    panic("init exiting");
80104636:	c7 04 24 46 8b 10 80 	movl   $0x80108b46,(%esp)
8010463d:	e8 12 bf ff ff       	call   80100554 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104642:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104649:	eb 3a                	jmp    80104685 <exit+0x67>
    if(curproc->ofile[fd]){
8010464b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010464e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104651:	83 c2 08             	add    $0x8,%edx
80104654:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104658:	85 c0                	test   %eax,%eax
8010465a:	74 26                	je     80104682 <exit+0x64>
      fileclose(curproc->ofile[fd]);
8010465c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010465f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104662:	83 c2 08             	add    $0x8,%edx
80104665:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104669:	89 04 24             	mov    %eax,(%esp)
8010466c:	e8 33 ca ff ff       	call   801010a4 <fileclose>
      curproc->ofile[fd] = 0;
80104671:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104674:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104677:	83 c2 08             	add    $0x8,%edx
8010467a:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104681:	00 

  if(curproc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104682:	ff 45 f0             	incl   -0x10(%ebp)
80104685:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104689:	7e c0                	jle    8010464b <exit+0x2d>
      fileclose(curproc->ofile[fd]);
      curproc->ofile[fd] = 0;
    }
  }

  begin_op();
8010468b:	e8 27 ee ff ff       	call   801034b7 <begin_op>
  iput(curproc->cwd);
80104690:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104693:	8b 40 68             	mov    0x68(%eax),%eax
80104696:	89 04 24             	mov    %eax,(%esp)
80104699:	e8 6e d4 ff ff       	call   80101b0c <iput>
  end_op();
8010469e:	e8 96 ee ff ff       	call   80103539 <end_op>
  curproc->cwd = 0;
801046a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801046a6:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801046ad:	c7 04 24 40 40 11 80 	movl   $0x80114040,(%esp)
801046b4:	e8 12 07 00 00       	call   80104dcb <acquire>

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
801046b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801046bc:	8b 40 14             	mov    0x14(%eax),%eax
801046bf:	89 04 24             	mov    %eax,(%esp)
801046c2:	e8 cc 03 00 00       	call   80104a93 <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801046c7:	c7 45 f4 74 40 11 80 	movl   $0x80114074,-0xc(%ebp)
801046ce:	eb 33                	jmp    80104703 <exit+0xe5>
    if(p->parent == curproc){
801046d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d3:	8b 40 14             	mov    0x14(%eax),%eax
801046d6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801046d9:	75 24                	jne    801046ff <exit+0xe1>
      p->parent = initproc;
801046db:	8b 15 c0 b8 10 80    	mov    0x8010b8c0,%edx
801046e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046e4:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801046e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046ea:	8b 40 0c             	mov    0xc(%eax),%eax
801046ed:	83 f8 05             	cmp    $0x5,%eax
801046f0:	75 0d                	jne    801046ff <exit+0xe1>
        wakeup1(initproc);
801046f2:	a1 c0 b8 10 80       	mov    0x8010b8c0,%eax
801046f7:	89 04 24             	mov    %eax,(%esp)
801046fa:	e8 94 03 00 00       	call   80104a93 <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801046ff:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104703:	81 7d f4 74 60 11 80 	cmpl   $0x80116074,-0xc(%ebp)
8010470a:	72 c4                	jb     801046d0 <exit+0xb2>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
8010470c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010470f:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104716:	e8 c3 01 00 00       	call   801048de <sched>
  panic("zombie exit");
8010471b:	c7 04 24 53 8b 10 80 	movl   $0x80108b53,(%esp)
80104722:	e8 2d be ff ff       	call   80100554 <panic>

80104727 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104727:	55                   	push   %ebp
80104728:	89 e5                	mov    %esp,%ebp
8010472a:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
8010472d:	e8 7d fa ff ff       	call   801041af <myproc>
80104732:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80104735:	c7 04 24 40 40 11 80 	movl   $0x80114040,(%esp)
8010473c:	e8 8a 06 00 00       	call   80104dcb <acquire>
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104741:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104748:	c7 45 f4 74 40 11 80 	movl   $0x80114074,-0xc(%ebp)
8010474f:	e9 95 00 00 00       	jmp    801047e9 <wait+0xc2>
      if(p->parent != curproc)
80104754:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104757:	8b 40 14             	mov    0x14(%eax),%eax
8010475a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010475d:	74 05                	je     80104764 <wait+0x3d>
        continue;
8010475f:	e9 81 00 00 00       	jmp    801047e5 <wait+0xbe>
      havekids = 1;
80104764:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
8010476b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010476e:	8b 40 0c             	mov    0xc(%eax),%eax
80104771:	83 f8 05             	cmp    $0x5,%eax
80104774:	75 6f                	jne    801047e5 <wait+0xbe>
        // Found one.
        pid = p->pid;
80104776:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104779:	8b 40 10             	mov    0x10(%eax),%eax
8010477c:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
8010477f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104782:	8b 40 08             	mov    0x8(%eax),%eax
80104785:	89 04 24             	mov    %eax,(%esp)
80104788:	e8 cc e3 ff ff       	call   80102b59 <kfree>
        p->kstack = 0;
8010478d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104790:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104797:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010479a:	8b 40 04             	mov    0x4(%eax),%eax
8010479d:	89 04 24             	mov    %eax,(%esp)
801047a0:	e8 f7 39 00 00       	call   8010819c <freevm>
        p->pid = 0;
801047a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047a8:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801047af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047b2:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
801047b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047bc:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
801047c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047c3:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
801047ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047cd:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
801047d4:	c7 04 24 40 40 11 80 	movl   $0x80114040,(%esp)
801047db:	e8 55 06 00 00       	call   80104e35 <release>
        return pid;
801047e0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801047e3:	eb 4c                	jmp    80104831 <wait+0x10a>
  
  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801047e5:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801047e9:	81 7d f4 74 60 11 80 	cmpl   $0x80116074,-0xc(%ebp)
801047f0:	0f 82 5e ff ff ff    	jb     80104754 <wait+0x2d>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
801047f6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801047fa:	74 0a                	je     80104806 <wait+0xdf>
801047fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047ff:	8b 40 24             	mov    0x24(%eax),%eax
80104802:	85 c0                	test   %eax,%eax
80104804:	74 13                	je     80104819 <wait+0xf2>
      release(&ptable.lock);
80104806:	c7 04 24 40 40 11 80 	movl   $0x80114040,(%esp)
8010480d:	e8 23 06 00 00       	call   80104e35 <release>
      return -1;
80104812:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104817:	eb 18                	jmp    80104831 <wait+0x10a>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80104819:	c7 44 24 04 40 40 11 	movl   $0x80114040,0x4(%esp)
80104820:	80 
80104821:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104824:	89 04 24             	mov    %eax,(%esp)
80104827:	e8 d1 01 00 00       	call   801049fd <sleep>
  }
8010482c:	e9 10 ff ff ff       	jmp    80104741 <wait+0x1a>
}
80104831:	c9                   	leave  
80104832:	c3                   	ret    

80104833 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104833:	55                   	push   %ebp
80104834:	89 e5                	mov    %esp,%ebp
80104836:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104839:	e8 ed f8 ff ff       	call   8010412b <mycpu>
8010483e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104841:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104844:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010484b:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
8010484e:	e8 71 f8 ff ff       	call   801040c4 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104853:	c7 04 24 40 40 11 80 	movl   $0x80114040,(%esp)
8010485a:	e8 6c 05 00 00       	call   80104dcb <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010485f:	c7 45 f4 74 40 11 80 	movl   $0x80114074,-0xc(%ebp)
80104866:	eb 5c                	jmp    801048c4 <scheduler+0x91>
      if(p->state != RUNNABLE)
80104868:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010486b:	8b 40 0c             	mov    0xc(%eax),%eax
8010486e:	83 f8 03             	cmp    $0x3,%eax
80104871:	74 02                	je     80104875 <scheduler+0x42>
        continue;
80104873:	eb 4b                	jmp    801048c0 <scheduler+0x8d>

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104875:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104878:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010487b:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104881:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104884:	89 04 24             	mov    %eax,(%esp)
80104887:	e8 44 34 00 00       	call   80107cd0 <switchuvm>
      p->state = RUNNING;
8010488c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010488f:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104896:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104899:	8b 40 1c             	mov    0x1c(%eax),%eax
8010489c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010489f:	83 c2 04             	add    $0x4,%edx
801048a2:	89 44 24 04          	mov    %eax,0x4(%esp)
801048a6:	89 14 24             	mov    %edx,(%esp)
801048a9:	e8 fa 09 00 00       	call   801052a8 <swtch>
      switchkvm();
801048ae:	e8 03 34 00 00       	call   80107cb6 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
801048b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048b6:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801048bd:	00 00 00 
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048c0:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801048c4:	81 7d f4 74 60 11 80 	cmpl   $0x80116074,-0xc(%ebp)
801048cb:	72 9b                	jb     80104868 <scheduler+0x35>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
    }
    release(&ptable.lock);
801048cd:	c7 04 24 40 40 11 80 	movl   $0x80114040,(%esp)
801048d4:	e8 5c 05 00 00       	call   80104e35 <release>

  }
801048d9:	e9 70 ff ff ff       	jmp    8010484e <scheduler+0x1b>

801048de <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
801048de:	55                   	push   %ebp
801048df:	89 e5                	mov    %esp,%ebp
801048e1:	83 ec 28             	sub    $0x28,%esp
  int intena;
  struct proc *p = myproc();
801048e4:	e8 c6 f8 ff ff       	call   801041af <myproc>
801048e9:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
801048ec:	c7 04 24 40 40 11 80 	movl   $0x80114040,(%esp)
801048f3:	e8 01 06 00 00       	call   80104ef9 <holding>
801048f8:	85 c0                	test   %eax,%eax
801048fa:	75 0c                	jne    80104908 <sched+0x2a>
    panic("sched ptable.lock");
801048fc:	c7 04 24 5f 8b 10 80 	movl   $0x80108b5f,(%esp)
80104903:	e8 4c bc ff ff       	call   80100554 <panic>
  if(mycpu()->ncli != 1)
80104908:	e8 1e f8 ff ff       	call   8010412b <mycpu>
8010490d:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104913:	83 f8 01             	cmp    $0x1,%eax
80104916:	74 0c                	je     80104924 <sched+0x46>
    panic("sched locks");
80104918:	c7 04 24 71 8b 10 80 	movl   $0x80108b71,(%esp)
8010491f:	e8 30 bc ff ff       	call   80100554 <panic>
  if(p->state == RUNNING)
80104924:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104927:	8b 40 0c             	mov    0xc(%eax),%eax
8010492a:	83 f8 04             	cmp    $0x4,%eax
8010492d:	75 0c                	jne    8010493b <sched+0x5d>
    panic("sched running");
8010492f:	c7 04 24 7d 8b 10 80 	movl   $0x80108b7d,(%esp)
80104936:	e8 19 bc ff ff       	call   80100554 <panic>
  if(readeflags()&FL_IF)
8010493b:	e8 74 f7 ff ff       	call   801040b4 <readeflags>
80104940:	25 00 02 00 00       	and    $0x200,%eax
80104945:	85 c0                	test   %eax,%eax
80104947:	74 0c                	je     80104955 <sched+0x77>
    panic("sched interruptible");
80104949:	c7 04 24 8b 8b 10 80 	movl   $0x80108b8b,(%esp)
80104950:	e8 ff bb ff ff       	call   80100554 <panic>
  intena = mycpu()->intena;
80104955:	e8 d1 f7 ff ff       	call   8010412b <mycpu>
8010495a:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104960:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104963:	e8 c3 f7 ff ff       	call   8010412b <mycpu>
80104968:	8b 40 04             	mov    0x4(%eax),%eax
8010496b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010496e:	83 c2 1c             	add    $0x1c,%edx
80104971:	89 44 24 04          	mov    %eax,0x4(%esp)
80104975:	89 14 24             	mov    %edx,(%esp)
80104978:	e8 2b 09 00 00       	call   801052a8 <swtch>
  mycpu()->intena = intena;
8010497d:	e8 a9 f7 ff ff       	call   8010412b <mycpu>
80104982:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104985:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
8010498b:	c9                   	leave  
8010498c:	c3                   	ret    

8010498d <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
8010498d:	55                   	push   %ebp
8010498e:	89 e5                	mov    %esp,%ebp
80104990:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104993:	c7 04 24 40 40 11 80 	movl   $0x80114040,(%esp)
8010499a:	e8 2c 04 00 00       	call   80104dcb <acquire>
  myproc()->state = RUNNABLE;
8010499f:	e8 0b f8 ff ff       	call   801041af <myproc>
801049a4:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
801049ab:	e8 2e ff ff ff       	call   801048de <sched>
  release(&ptable.lock);
801049b0:	c7 04 24 40 40 11 80 	movl   $0x80114040,(%esp)
801049b7:	e8 79 04 00 00       	call   80104e35 <release>
}
801049bc:	c9                   	leave  
801049bd:	c3                   	ret    

801049be <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
801049be:	55                   	push   %ebp
801049bf:	89 e5                	mov    %esp,%ebp
801049c1:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
801049c4:	c7 04 24 40 40 11 80 	movl   $0x80114040,(%esp)
801049cb:	e8 65 04 00 00       	call   80104e35 <release>

  if (first) {
801049d0:	a1 04 b0 10 80       	mov    0x8010b004,%eax
801049d5:	85 c0                	test   %eax,%eax
801049d7:	74 22                	je     801049fb <forkret+0x3d>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
801049d9:	c7 05 04 b0 10 80 00 	movl   $0x0,0x8010b004
801049e0:	00 00 00 
    iinit(ROOTDEV);
801049e3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801049ea:	e8 68 cc ff ff       	call   80101657 <iinit>
    initlog(ROOTDEV);
801049ef:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801049f6:	e8 bd e8 ff ff       	call   801032b8 <initlog>
  }

  // Return to "caller", actually trapret (see allocproc).
}
801049fb:	c9                   	leave  
801049fc:	c3                   	ret    

801049fd <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801049fd:	55                   	push   %ebp
801049fe:	89 e5                	mov    %esp,%ebp
80104a00:	83 ec 28             	sub    $0x28,%esp
  struct proc *p = myproc();
80104a03:	e8 a7 f7 ff ff       	call   801041af <myproc>
80104a08:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104a0b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104a0f:	75 0c                	jne    80104a1d <sleep+0x20>
    panic("sleep");
80104a11:	c7 04 24 9f 8b 10 80 	movl   $0x80108b9f,(%esp)
80104a18:	e8 37 bb ff ff       	call   80100554 <panic>

  if(lk == 0)
80104a1d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104a21:	75 0c                	jne    80104a2f <sleep+0x32>
    panic("sleep without lk");
80104a23:	c7 04 24 a5 8b 10 80 	movl   $0x80108ba5,(%esp)
80104a2a:	e8 25 bb ff ff       	call   80100554 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104a2f:	81 7d 0c 40 40 11 80 	cmpl   $0x80114040,0xc(%ebp)
80104a36:	74 17                	je     80104a4f <sleep+0x52>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104a38:	c7 04 24 40 40 11 80 	movl   $0x80114040,(%esp)
80104a3f:	e8 87 03 00 00       	call   80104dcb <acquire>
    release(lk);
80104a44:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a47:	89 04 24             	mov    %eax,(%esp)
80104a4a:	e8 e6 03 00 00       	call   80104e35 <release>
  }
  // Go to sleep.
  p->chan = chan;
80104a4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a52:	8b 55 08             	mov    0x8(%ebp),%edx
80104a55:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104a58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a5b:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104a62:	e8 77 fe ff ff       	call   801048de <sched>

  // Tidy up.
  p->chan = 0;
80104a67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a6a:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104a71:	81 7d 0c 40 40 11 80 	cmpl   $0x80114040,0xc(%ebp)
80104a78:	74 17                	je     80104a91 <sleep+0x94>
    release(&ptable.lock);
80104a7a:	c7 04 24 40 40 11 80 	movl   $0x80114040,(%esp)
80104a81:	e8 af 03 00 00       	call   80104e35 <release>
    acquire(lk);
80104a86:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a89:	89 04 24             	mov    %eax,(%esp)
80104a8c:	e8 3a 03 00 00       	call   80104dcb <acquire>
  }
}
80104a91:	c9                   	leave  
80104a92:	c3                   	ret    

80104a93 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104a93:	55                   	push   %ebp
80104a94:	89 e5                	mov    %esp,%ebp
80104a96:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104a99:	c7 45 fc 74 40 11 80 	movl   $0x80114074,-0x4(%ebp)
80104aa0:	eb 24                	jmp    80104ac6 <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104aa2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104aa5:	8b 40 0c             	mov    0xc(%eax),%eax
80104aa8:	83 f8 02             	cmp    $0x2,%eax
80104aab:	75 15                	jne    80104ac2 <wakeup1+0x2f>
80104aad:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ab0:	8b 40 20             	mov    0x20(%eax),%eax
80104ab3:	3b 45 08             	cmp    0x8(%ebp),%eax
80104ab6:	75 0a                	jne    80104ac2 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104ab8:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104abb:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104ac2:	83 6d fc 80          	subl   $0xffffff80,-0x4(%ebp)
80104ac6:	81 7d fc 74 60 11 80 	cmpl   $0x80116074,-0x4(%ebp)
80104acd:	72 d3                	jb     80104aa2 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104acf:	c9                   	leave  
80104ad0:	c3                   	ret    

80104ad1 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104ad1:	55                   	push   %ebp
80104ad2:	89 e5                	mov    %esp,%ebp
80104ad4:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104ad7:	c7 04 24 40 40 11 80 	movl   $0x80114040,(%esp)
80104ade:	e8 e8 02 00 00       	call   80104dcb <acquire>
  wakeup1(chan);
80104ae3:	8b 45 08             	mov    0x8(%ebp),%eax
80104ae6:	89 04 24             	mov    %eax,(%esp)
80104ae9:	e8 a5 ff ff ff       	call   80104a93 <wakeup1>
  release(&ptable.lock);
80104aee:	c7 04 24 40 40 11 80 	movl   $0x80114040,(%esp)
80104af5:	e8 3b 03 00 00       	call   80104e35 <release>
}
80104afa:	c9                   	leave  
80104afb:	c3                   	ret    

80104afc <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104afc:	55                   	push   %ebp
80104afd:	89 e5                	mov    %esp,%ebp
80104aff:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104b02:	c7 04 24 40 40 11 80 	movl   $0x80114040,(%esp)
80104b09:	e8 bd 02 00 00       	call   80104dcb <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b0e:	c7 45 f4 74 40 11 80 	movl   $0x80114074,-0xc(%ebp)
80104b15:	eb 41                	jmp    80104b58 <kill+0x5c>
    if(p->pid == pid){
80104b17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b1a:	8b 40 10             	mov    0x10(%eax),%eax
80104b1d:	3b 45 08             	cmp    0x8(%ebp),%eax
80104b20:	75 32                	jne    80104b54 <kill+0x58>
      p->killed = 1;
80104b22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b25:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104b2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b2f:	8b 40 0c             	mov    0xc(%eax),%eax
80104b32:	83 f8 02             	cmp    $0x2,%eax
80104b35:	75 0a                	jne    80104b41 <kill+0x45>
        p->state = RUNNABLE;
80104b37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b3a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104b41:	c7 04 24 40 40 11 80 	movl   $0x80114040,(%esp)
80104b48:	e8 e8 02 00 00       	call   80104e35 <release>
      return 0;
80104b4d:	b8 00 00 00 00       	mov    $0x0,%eax
80104b52:	eb 1e                	jmp    80104b72 <kill+0x76>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b54:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104b58:	81 7d f4 74 60 11 80 	cmpl   $0x80116074,-0xc(%ebp)
80104b5f:	72 b6                	jb     80104b17 <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104b61:	c7 04 24 40 40 11 80 	movl   $0x80114040,(%esp)
80104b68:	e8 c8 02 00 00       	call   80104e35 <release>
  return -1;
80104b6d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104b72:	c9                   	leave  
80104b73:	c3                   	ret    

80104b74 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104b74:	55                   	push   %ebp
80104b75:	89 e5                	mov    %esp,%ebp
80104b77:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b7a:	c7 45 f0 74 40 11 80 	movl   $0x80114074,-0x10(%ebp)
80104b81:	e9 d5 00 00 00       	jmp    80104c5b <procdump+0xe7>
    if(p->state == UNUSED)
80104b86:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b89:	8b 40 0c             	mov    0xc(%eax),%eax
80104b8c:	85 c0                	test   %eax,%eax
80104b8e:	75 05                	jne    80104b95 <procdump+0x21>
      continue;
80104b90:	e9 c2 00 00 00       	jmp    80104c57 <procdump+0xe3>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104b95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b98:	8b 40 0c             	mov    0xc(%eax),%eax
80104b9b:	83 f8 05             	cmp    $0x5,%eax
80104b9e:	77 23                	ja     80104bc3 <procdump+0x4f>
80104ba0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ba3:	8b 40 0c             	mov    0xc(%eax),%eax
80104ba6:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104bad:	85 c0                	test   %eax,%eax
80104baf:	74 12                	je     80104bc3 <procdump+0x4f>
      state = states[p->state];
80104bb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104bb4:	8b 40 0c             	mov    0xc(%eax),%eax
80104bb7:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104bbe:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104bc1:	eb 07                	jmp    80104bca <procdump+0x56>
    else
      state = "???";
80104bc3:	c7 45 ec b6 8b 10 80 	movl   $0x80108bb6,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104bca:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104bcd:	8d 50 6c             	lea    0x6c(%eax),%edx
80104bd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104bd3:	8b 40 10             	mov    0x10(%eax),%eax
80104bd6:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104bda:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104bdd:	89 54 24 08          	mov    %edx,0x8(%esp)
80104be1:	89 44 24 04          	mov    %eax,0x4(%esp)
80104be5:	c7 04 24 ba 8b 10 80 	movl   $0x80108bba,(%esp)
80104bec:	e8 d0 b7 ff ff       	call   801003c1 <cprintf>
    if(p->state == SLEEPING){
80104bf1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104bf4:	8b 40 0c             	mov    0xc(%eax),%eax
80104bf7:	83 f8 02             	cmp    $0x2,%eax
80104bfa:	75 4f                	jne    80104c4b <procdump+0xd7>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104bfc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104bff:	8b 40 1c             	mov    0x1c(%eax),%eax
80104c02:	8b 40 0c             	mov    0xc(%eax),%eax
80104c05:	83 c0 08             	add    $0x8,%eax
80104c08:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80104c0b:	89 54 24 04          	mov    %edx,0x4(%esp)
80104c0f:	89 04 24             	mov    %eax,(%esp)
80104c12:	e8 6b 02 00 00       	call   80104e82 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104c17:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104c1e:	eb 1a                	jmp    80104c3a <procdump+0xc6>
        cprintf(" %p", pc[i]);
80104c20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c23:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104c27:	89 44 24 04          	mov    %eax,0x4(%esp)
80104c2b:	c7 04 24 c3 8b 10 80 	movl   $0x80108bc3,(%esp)
80104c32:	e8 8a b7 ff ff       	call   801003c1 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104c37:	ff 45 f4             	incl   -0xc(%ebp)
80104c3a:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104c3e:	7f 0b                	jg     80104c4b <procdump+0xd7>
80104c40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c43:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104c47:	85 c0                	test   %eax,%eax
80104c49:	75 d5                	jne    80104c20 <procdump+0xac>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104c4b:	c7 04 24 c7 8b 10 80 	movl   $0x80108bc7,(%esp)
80104c52:	e8 6a b7 ff ff       	call   801003c1 <cprintf>
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c57:	83 6d f0 80          	subl   $0xffffff80,-0x10(%ebp)
80104c5b:	81 7d f0 74 60 11 80 	cmpl   $0x80116074,-0x10(%ebp)
80104c62:	0f 82 1e ff ff ff    	jb     80104b86 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104c68:	c9                   	leave  
80104c69:	c3                   	ret    
	...

80104c6c <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104c6c:	55                   	push   %ebp
80104c6d:	89 e5                	mov    %esp,%ebp
80104c6f:	83 ec 18             	sub    $0x18,%esp
  initlock(&lk->lk, "sleep lock");
80104c72:	8b 45 08             	mov    0x8(%ebp),%eax
80104c75:	83 c0 04             	add    $0x4,%eax
80104c78:	c7 44 24 04 f3 8b 10 	movl   $0x80108bf3,0x4(%esp)
80104c7f:	80 
80104c80:	89 04 24             	mov    %eax,(%esp)
80104c83:	e8 22 01 00 00       	call   80104daa <initlock>
  lk->name = name;
80104c88:	8b 45 08             	mov    0x8(%ebp),%eax
80104c8b:	8b 55 0c             	mov    0xc(%ebp),%edx
80104c8e:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104c91:	8b 45 08             	mov    0x8(%ebp),%eax
80104c94:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104c9a:	8b 45 08             	mov    0x8(%ebp),%eax
80104c9d:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104ca4:	c9                   	leave  
80104ca5:	c3                   	ret    

80104ca6 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104ca6:	55                   	push   %ebp
80104ca7:	89 e5                	mov    %esp,%ebp
80104ca9:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
80104cac:	8b 45 08             	mov    0x8(%ebp),%eax
80104caf:	83 c0 04             	add    $0x4,%eax
80104cb2:	89 04 24             	mov    %eax,(%esp)
80104cb5:	e8 11 01 00 00       	call   80104dcb <acquire>
  while (lk->locked) {
80104cba:	eb 15                	jmp    80104cd1 <acquiresleep+0x2b>
    sleep(lk, &lk->lk);
80104cbc:	8b 45 08             	mov    0x8(%ebp),%eax
80104cbf:	83 c0 04             	add    $0x4,%eax
80104cc2:	89 44 24 04          	mov    %eax,0x4(%esp)
80104cc6:	8b 45 08             	mov    0x8(%ebp),%eax
80104cc9:	89 04 24             	mov    %eax,(%esp)
80104ccc:	e8 2c fd ff ff       	call   801049fd <sleep>

void
acquiresleep(struct sleeplock *lk)
{
  acquire(&lk->lk);
  while (lk->locked) {
80104cd1:	8b 45 08             	mov    0x8(%ebp),%eax
80104cd4:	8b 00                	mov    (%eax),%eax
80104cd6:	85 c0                	test   %eax,%eax
80104cd8:	75 e2                	jne    80104cbc <acquiresleep+0x16>
    sleep(lk, &lk->lk);
  }
  lk->locked = 1;
80104cda:	8b 45 08             	mov    0x8(%ebp),%eax
80104cdd:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104ce3:	e8 c7 f4 ff ff       	call   801041af <myproc>
80104ce8:	8b 50 10             	mov    0x10(%eax),%edx
80104ceb:	8b 45 08             	mov    0x8(%ebp),%eax
80104cee:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104cf1:	8b 45 08             	mov    0x8(%ebp),%eax
80104cf4:	83 c0 04             	add    $0x4,%eax
80104cf7:	89 04 24             	mov    %eax,(%esp)
80104cfa:	e8 36 01 00 00       	call   80104e35 <release>
}
80104cff:	c9                   	leave  
80104d00:	c3                   	ret    

80104d01 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104d01:	55                   	push   %ebp
80104d02:	89 e5                	mov    %esp,%ebp
80104d04:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
80104d07:	8b 45 08             	mov    0x8(%ebp),%eax
80104d0a:	83 c0 04             	add    $0x4,%eax
80104d0d:	89 04 24             	mov    %eax,(%esp)
80104d10:	e8 b6 00 00 00       	call   80104dcb <acquire>
  lk->locked = 0;
80104d15:	8b 45 08             	mov    0x8(%ebp),%eax
80104d18:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104d1e:	8b 45 08             	mov    0x8(%ebp),%eax
80104d21:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104d28:	8b 45 08             	mov    0x8(%ebp),%eax
80104d2b:	89 04 24             	mov    %eax,(%esp)
80104d2e:	e8 9e fd ff ff       	call   80104ad1 <wakeup>
  release(&lk->lk);
80104d33:	8b 45 08             	mov    0x8(%ebp),%eax
80104d36:	83 c0 04             	add    $0x4,%eax
80104d39:	89 04 24             	mov    %eax,(%esp)
80104d3c:	e8 f4 00 00 00       	call   80104e35 <release>
}
80104d41:	c9                   	leave  
80104d42:	c3                   	ret    

80104d43 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104d43:	55                   	push   %ebp
80104d44:	89 e5                	mov    %esp,%ebp
80104d46:	83 ec 28             	sub    $0x28,%esp
  int r;
  
  acquire(&lk->lk);
80104d49:	8b 45 08             	mov    0x8(%ebp),%eax
80104d4c:	83 c0 04             	add    $0x4,%eax
80104d4f:	89 04 24             	mov    %eax,(%esp)
80104d52:	e8 74 00 00 00       	call   80104dcb <acquire>
  r = lk->locked;
80104d57:	8b 45 08             	mov    0x8(%ebp),%eax
80104d5a:	8b 00                	mov    (%eax),%eax
80104d5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104d5f:	8b 45 08             	mov    0x8(%ebp),%eax
80104d62:	83 c0 04             	add    $0x4,%eax
80104d65:	89 04 24             	mov    %eax,(%esp)
80104d68:	e8 c8 00 00 00       	call   80104e35 <release>
  return r;
80104d6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104d70:	c9                   	leave  
80104d71:	c3                   	ret    
	...

80104d74 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104d74:	55                   	push   %ebp
80104d75:	89 e5                	mov    %esp,%ebp
80104d77:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104d7a:	9c                   	pushf  
80104d7b:	58                   	pop    %eax
80104d7c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104d7f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104d82:	c9                   	leave  
80104d83:	c3                   	ret    

80104d84 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80104d84:	55                   	push   %ebp
80104d85:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104d87:	fa                   	cli    
}
80104d88:	5d                   	pop    %ebp
80104d89:	c3                   	ret    

80104d8a <sti>:

static inline void
sti(void)
{
80104d8a:	55                   	push   %ebp
80104d8b:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104d8d:	fb                   	sti    
}
80104d8e:	5d                   	pop    %ebp
80104d8f:	c3                   	ret    

80104d90 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80104d90:	55                   	push   %ebp
80104d91:	89 e5                	mov    %esp,%ebp
80104d93:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80104d96:	8b 55 08             	mov    0x8(%ebp),%edx
80104d99:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d9c:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104d9f:	f0 87 02             	lock xchg %eax,(%edx)
80104da2:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80104da5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104da8:	c9                   	leave  
80104da9:	c3                   	ret    

80104daa <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104daa:	55                   	push   %ebp
80104dab:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104dad:	8b 45 08             	mov    0x8(%ebp),%eax
80104db0:	8b 55 0c             	mov    0xc(%ebp),%edx
80104db3:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104db6:	8b 45 08             	mov    0x8(%ebp),%eax
80104db9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104dbf:	8b 45 08             	mov    0x8(%ebp),%eax
80104dc2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104dc9:	5d                   	pop    %ebp
80104dca:	c3                   	ret    

80104dcb <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104dcb:	55                   	push   %ebp
80104dcc:	89 e5                	mov    %esp,%ebp
80104dce:	53                   	push   %ebx
80104dcf:	83 ec 14             	sub    $0x14,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104dd2:	e8 53 01 00 00       	call   80104f2a <pushcli>
  if(holding(lk))
80104dd7:	8b 45 08             	mov    0x8(%ebp),%eax
80104dda:	89 04 24             	mov    %eax,(%esp)
80104ddd:	e8 17 01 00 00       	call   80104ef9 <holding>
80104de2:	85 c0                	test   %eax,%eax
80104de4:	74 0c                	je     80104df2 <acquire+0x27>
    panic("acquire");
80104de6:	c7 04 24 fe 8b 10 80 	movl   $0x80108bfe,(%esp)
80104ded:	e8 62 b7 ff ff       	call   80100554 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104df2:	90                   	nop
80104df3:	8b 45 08             	mov    0x8(%ebp),%eax
80104df6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80104dfd:	00 
80104dfe:	89 04 24             	mov    %eax,(%esp)
80104e01:	e8 8a ff ff ff       	call   80104d90 <xchg>
80104e06:	85 c0                	test   %eax,%eax
80104e08:	75 e9                	jne    80104df3 <acquire+0x28>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104e0a:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104e0f:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104e12:	e8 14 f3 ff ff       	call   8010412b <mycpu>
80104e17:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104e1a:	8b 45 08             	mov    0x8(%ebp),%eax
80104e1d:	83 c0 0c             	add    $0xc,%eax
80104e20:	89 44 24 04          	mov    %eax,0x4(%esp)
80104e24:	8d 45 08             	lea    0x8(%ebp),%eax
80104e27:	89 04 24             	mov    %eax,(%esp)
80104e2a:	e8 53 00 00 00       	call   80104e82 <getcallerpcs>
}
80104e2f:	83 c4 14             	add    $0x14,%esp
80104e32:	5b                   	pop    %ebx
80104e33:	5d                   	pop    %ebp
80104e34:	c3                   	ret    

80104e35 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104e35:	55                   	push   %ebp
80104e36:	89 e5                	mov    %esp,%ebp
80104e38:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
80104e3b:	8b 45 08             	mov    0x8(%ebp),%eax
80104e3e:	89 04 24             	mov    %eax,(%esp)
80104e41:	e8 b3 00 00 00       	call   80104ef9 <holding>
80104e46:	85 c0                	test   %eax,%eax
80104e48:	75 0c                	jne    80104e56 <release+0x21>
    panic("release");
80104e4a:	c7 04 24 06 8c 10 80 	movl   $0x80108c06,(%esp)
80104e51:	e8 fe b6 ff ff       	call   80100554 <panic>

  lk->pcs[0] = 0;
80104e56:	8b 45 08             	mov    0x8(%ebp),%eax
80104e59:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104e60:	8b 45 08             	mov    0x8(%ebp),%eax
80104e63:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80104e6a:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104e6f:	8b 45 08             	mov    0x8(%ebp),%eax
80104e72:	8b 55 08             	mov    0x8(%ebp),%edx
80104e75:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80104e7b:	e8 f4 00 00 00       	call   80104f74 <popcli>
}
80104e80:	c9                   	leave  
80104e81:	c3                   	ret    

80104e82 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104e82:	55                   	push   %ebp
80104e83:	89 e5                	mov    %esp,%ebp
80104e85:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104e88:	8b 45 08             	mov    0x8(%ebp),%eax
80104e8b:	83 e8 08             	sub    $0x8,%eax
80104e8e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104e91:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104e98:	eb 37                	jmp    80104ed1 <getcallerpcs+0x4f>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104e9a:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104e9e:	74 37                	je     80104ed7 <getcallerpcs+0x55>
80104ea0:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104ea7:	76 2e                	jbe    80104ed7 <getcallerpcs+0x55>
80104ea9:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104ead:	74 28                	je     80104ed7 <getcallerpcs+0x55>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104eaf:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104eb2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104eb9:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ebc:	01 c2                	add    %eax,%edx
80104ebe:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ec1:	8b 40 04             	mov    0x4(%eax),%eax
80104ec4:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104ec6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ec9:	8b 00                	mov    (%eax),%eax
80104ecb:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80104ece:	ff 45 f8             	incl   -0x8(%ebp)
80104ed1:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104ed5:	7e c3                	jle    80104e9a <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80104ed7:	eb 18                	jmp    80104ef1 <getcallerpcs+0x6f>
    pcs[i] = 0;
80104ed9:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104edc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104ee3:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ee6:	01 d0                	add    %edx,%eax
80104ee8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80104eee:	ff 45 f8             	incl   -0x8(%ebp)
80104ef1:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104ef5:	7e e2                	jle    80104ed9 <getcallerpcs+0x57>
    pcs[i] = 0;
}
80104ef7:	c9                   	leave  
80104ef8:	c3                   	ret    

80104ef9 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104ef9:	55                   	push   %ebp
80104efa:	89 e5                	mov    %esp,%ebp
80104efc:	53                   	push   %ebx
80104efd:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104f00:	8b 45 08             	mov    0x8(%ebp),%eax
80104f03:	8b 00                	mov    (%eax),%eax
80104f05:	85 c0                	test   %eax,%eax
80104f07:	74 16                	je     80104f1f <holding+0x26>
80104f09:	8b 45 08             	mov    0x8(%ebp),%eax
80104f0c:	8b 58 08             	mov    0x8(%eax),%ebx
80104f0f:	e8 17 f2 ff ff       	call   8010412b <mycpu>
80104f14:	39 c3                	cmp    %eax,%ebx
80104f16:	75 07                	jne    80104f1f <holding+0x26>
80104f18:	b8 01 00 00 00       	mov    $0x1,%eax
80104f1d:	eb 05                	jmp    80104f24 <holding+0x2b>
80104f1f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104f24:	83 c4 04             	add    $0x4,%esp
80104f27:	5b                   	pop    %ebx
80104f28:	5d                   	pop    %ebp
80104f29:	c3                   	ret    

80104f2a <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104f2a:	55                   	push   %ebp
80104f2b:	89 e5                	mov    %esp,%ebp
80104f2d:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80104f30:	e8 3f fe ff ff       	call   80104d74 <readeflags>
80104f35:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104f38:	e8 47 fe ff ff       	call   80104d84 <cli>
  if(mycpu()->ncli == 0)
80104f3d:	e8 e9 f1 ff ff       	call   8010412b <mycpu>
80104f42:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104f48:	85 c0                	test   %eax,%eax
80104f4a:	75 14                	jne    80104f60 <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
80104f4c:	e8 da f1 ff ff       	call   8010412b <mycpu>
80104f51:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f54:	81 e2 00 02 00 00    	and    $0x200,%edx
80104f5a:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80104f60:	e8 c6 f1 ff ff       	call   8010412b <mycpu>
80104f65:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104f6b:	42                   	inc    %edx
80104f6c:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80104f72:	c9                   	leave  
80104f73:	c3                   	ret    

80104f74 <popcli>:

void
popcli(void)
{
80104f74:	55                   	push   %ebp
80104f75:	89 e5                	mov    %esp,%ebp
80104f77:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
80104f7a:	e8 f5 fd ff ff       	call   80104d74 <readeflags>
80104f7f:	25 00 02 00 00       	and    $0x200,%eax
80104f84:	85 c0                	test   %eax,%eax
80104f86:	74 0c                	je     80104f94 <popcli+0x20>
    panic("popcli - interruptible");
80104f88:	c7 04 24 0e 8c 10 80 	movl   $0x80108c0e,(%esp)
80104f8f:	e8 c0 b5 ff ff       	call   80100554 <panic>
  if(--mycpu()->ncli < 0)
80104f94:	e8 92 f1 ff ff       	call   8010412b <mycpu>
80104f99:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104f9f:	4a                   	dec    %edx
80104fa0:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104fa6:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104fac:	85 c0                	test   %eax,%eax
80104fae:	79 0c                	jns    80104fbc <popcli+0x48>
    panic("popcli");
80104fb0:	c7 04 24 25 8c 10 80 	movl   $0x80108c25,(%esp)
80104fb7:	e8 98 b5 ff ff       	call   80100554 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104fbc:	e8 6a f1 ff ff       	call   8010412b <mycpu>
80104fc1:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104fc7:	85 c0                	test   %eax,%eax
80104fc9:	75 14                	jne    80104fdf <popcli+0x6b>
80104fcb:	e8 5b f1 ff ff       	call   8010412b <mycpu>
80104fd0:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104fd6:	85 c0                	test   %eax,%eax
80104fd8:	74 05                	je     80104fdf <popcli+0x6b>
    sti();
80104fda:	e8 ab fd ff ff       	call   80104d8a <sti>
}
80104fdf:	c9                   	leave  
80104fe0:	c3                   	ret    
80104fe1:	00 00                	add    %al,(%eax)
	...

80104fe4 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80104fe4:	55                   	push   %ebp
80104fe5:	89 e5                	mov    %esp,%ebp
80104fe7:	57                   	push   %edi
80104fe8:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104fe9:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104fec:	8b 55 10             	mov    0x10(%ebp),%edx
80104fef:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ff2:	89 cb                	mov    %ecx,%ebx
80104ff4:	89 df                	mov    %ebx,%edi
80104ff6:	89 d1                	mov    %edx,%ecx
80104ff8:	fc                   	cld    
80104ff9:	f3 aa                	rep stos %al,%es:(%edi)
80104ffb:	89 ca                	mov    %ecx,%edx
80104ffd:	89 fb                	mov    %edi,%ebx
80104fff:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105002:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105005:	5b                   	pop    %ebx
80105006:	5f                   	pop    %edi
80105007:	5d                   	pop    %ebp
80105008:	c3                   	ret    

80105009 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105009:	55                   	push   %ebp
8010500a:	89 e5                	mov    %esp,%ebp
8010500c:	57                   	push   %edi
8010500d:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
8010500e:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105011:	8b 55 10             	mov    0x10(%ebp),%edx
80105014:	8b 45 0c             	mov    0xc(%ebp),%eax
80105017:	89 cb                	mov    %ecx,%ebx
80105019:	89 df                	mov    %ebx,%edi
8010501b:	89 d1                	mov    %edx,%ecx
8010501d:	fc                   	cld    
8010501e:	f3 ab                	rep stos %eax,%es:(%edi)
80105020:	89 ca                	mov    %ecx,%edx
80105022:	89 fb                	mov    %edi,%ebx
80105024:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105027:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
8010502a:	5b                   	pop    %ebx
8010502b:	5f                   	pop    %edi
8010502c:	5d                   	pop    %ebp
8010502d:	c3                   	ret    

8010502e <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
8010502e:	55                   	push   %ebp
8010502f:	89 e5                	mov    %esp,%ebp
80105031:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
80105034:	8b 45 08             	mov    0x8(%ebp),%eax
80105037:	83 e0 03             	and    $0x3,%eax
8010503a:	85 c0                	test   %eax,%eax
8010503c:	75 49                	jne    80105087 <memset+0x59>
8010503e:	8b 45 10             	mov    0x10(%ebp),%eax
80105041:	83 e0 03             	and    $0x3,%eax
80105044:	85 c0                	test   %eax,%eax
80105046:	75 3f                	jne    80105087 <memset+0x59>
    c &= 0xFF;
80105048:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
8010504f:	8b 45 10             	mov    0x10(%ebp),%eax
80105052:	c1 e8 02             	shr    $0x2,%eax
80105055:	89 c2                	mov    %eax,%edx
80105057:	8b 45 0c             	mov    0xc(%ebp),%eax
8010505a:	c1 e0 18             	shl    $0x18,%eax
8010505d:	89 c1                	mov    %eax,%ecx
8010505f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105062:	c1 e0 10             	shl    $0x10,%eax
80105065:	09 c1                	or     %eax,%ecx
80105067:	8b 45 0c             	mov    0xc(%ebp),%eax
8010506a:	c1 e0 08             	shl    $0x8,%eax
8010506d:	09 c8                	or     %ecx,%eax
8010506f:	0b 45 0c             	or     0xc(%ebp),%eax
80105072:	89 54 24 08          	mov    %edx,0x8(%esp)
80105076:	89 44 24 04          	mov    %eax,0x4(%esp)
8010507a:	8b 45 08             	mov    0x8(%ebp),%eax
8010507d:	89 04 24             	mov    %eax,(%esp)
80105080:	e8 84 ff ff ff       	call   80105009 <stosl>
80105085:	eb 19                	jmp    801050a0 <memset+0x72>
  } else
    stosb(dst, c, n);
80105087:	8b 45 10             	mov    0x10(%ebp),%eax
8010508a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010508e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105091:	89 44 24 04          	mov    %eax,0x4(%esp)
80105095:	8b 45 08             	mov    0x8(%ebp),%eax
80105098:	89 04 24             	mov    %eax,(%esp)
8010509b:	e8 44 ff ff ff       	call   80104fe4 <stosb>
  return dst;
801050a0:	8b 45 08             	mov    0x8(%ebp),%eax
}
801050a3:	c9                   	leave  
801050a4:	c3                   	ret    

801050a5 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801050a5:	55                   	push   %ebp
801050a6:	89 e5                	mov    %esp,%ebp
801050a8:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
801050ab:	8b 45 08             	mov    0x8(%ebp),%eax
801050ae:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801050b1:	8b 45 0c             	mov    0xc(%ebp),%eax
801050b4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801050b7:	eb 2a                	jmp    801050e3 <memcmp+0x3e>
    if(*s1 != *s2)
801050b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050bc:	8a 10                	mov    (%eax),%dl
801050be:	8b 45 f8             	mov    -0x8(%ebp),%eax
801050c1:	8a 00                	mov    (%eax),%al
801050c3:	38 c2                	cmp    %al,%dl
801050c5:	74 16                	je     801050dd <memcmp+0x38>
      return *s1 - *s2;
801050c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050ca:	8a 00                	mov    (%eax),%al
801050cc:	0f b6 d0             	movzbl %al,%edx
801050cf:	8b 45 f8             	mov    -0x8(%ebp),%eax
801050d2:	8a 00                	mov    (%eax),%al
801050d4:	0f b6 c0             	movzbl %al,%eax
801050d7:	29 c2                	sub    %eax,%edx
801050d9:	89 d0                	mov    %edx,%eax
801050db:	eb 18                	jmp    801050f5 <memcmp+0x50>
    s1++, s2++;
801050dd:	ff 45 fc             	incl   -0x4(%ebp)
801050e0:	ff 45 f8             	incl   -0x8(%ebp)
{
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
801050e3:	8b 45 10             	mov    0x10(%ebp),%eax
801050e6:	8d 50 ff             	lea    -0x1(%eax),%edx
801050e9:	89 55 10             	mov    %edx,0x10(%ebp)
801050ec:	85 c0                	test   %eax,%eax
801050ee:	75 c9                	jne    801050b9 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
801050f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801050f5:	c9                   	leave  
801050f6:	c3                   	ret    

801050f7 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801050f7:	55                   	push   %ebp
801050f8:	89 e5                	mov    %esp,%ebp
801050fa:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801050fd:	8b 45 0c             	mov    0xc(%ebp),%eax
80105100:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105103:	8b 45 08             	mov    0x8(%ebp),%eax
80105106:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105109:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010510c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010510f:	73 3a                	jae    8010514b <memmove+0x54>
80105111:	8b 45 10             	mov    0x10(%ebp),%eax
80105114:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105117:	01 d0                	add    %edx,%eax
80105119:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010511c:	76 2d                	jbe    8010514b <memmove+0x54>
    s += n;
8010511e:	8b 45 10             	mov    0x10(%ebp),%eax
80105121:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105124:	8b 45 10             	mov    0x10(%ebp),%eax
80105127:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
8010512a:	eb 10                	jmp    8010513c <memmove+0x45>
      *--d = *--s;
8010512c:	ff 4d f8             	decl   -0x8(%ebp)
8010512f:	ff 4d fc             	decl   -0x4(%ebp)
80105132:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105135:	8a 10                	mov    (%eax),%dl
80105137:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010513a:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
8010513c:	8b 45 10             	mov    0x10(%ebp),%eax
8010513f:	8d 50 ff             	lea    -0x1(%eax),%edx
80105142:	89 55 10             	mov    %edx,0x10(%ebp)
80105145:	85 c0                	test   %eax,%eax
80105147:	75 e3                	jne    8010512c <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105149:	eb 25                	jmp    80105170 <memmove+0x79>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
8010514b:	eb 16                	jmp    80105163 <memmove+0x6c>
      *d++ = *s++;
8010514d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105150:	8d 50 01             	lea    0x1(%eax),%edx
80105153:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105156:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105159:	8d 4a 01             	lea    0x1(%edx),%ecx
8010515c:	89 4d fc             	mov    %ecx,-0x4(%ebp)
8010515f:	8a 12                	mov    (%edx),%dl
80105161:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105163:	8b 45 10             	mov    0x10(%ebp),%eax
80105166:	8d 50 ff             	lea    -0x1(%eax),%edx
80105169:	89 55 10             	mov    %edx,0x10(%ebp)
8010516c:	85 c0                	test   %eax,%eax
8010516e:	75 dd                	jne    8010514d <memmove+0x56>
      *d++ = *s++;

  return dst;
80105170:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105173:	c9                   	leave  
80105174:	c3                   	ret    

80105175 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105175:	55                   	push   %ebp
80105176:	89 e5                	mov    %esp,%ebp
80105178:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
8010517b:	8b 45 10             	mov    0x10(%ebp),%eax
8010517e:	89 44 24 08          	mov    %eax,0x8(%esp)
80105182:	8b 45 0c             	mov    0xc(%ebp),%eax
80105185:	89 44 24 04          	mov    %eax,0x4(%esp)
80105189:	8b 45 08             	mov    0x8(%ebp),%eax
8010518c:	89 04 24             	mov    %eax,(%esp)
8010518f:	e8 63 ff ff ff       	call   801050f7 <memmove>
}
80105194:	c9                   	leave  
80105195:	c3                   	ret    

80105196 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105196:	55                   	push   %ebp
80105197:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105199:	eb 09                	jmp    801051a4 <strncmp+0xe>
    n--, p++, q++;
8010519b:	ff 4d 10             	decl   0x10(%ebp)
8010519e:	ff 45 08             	incl   0x8(%ebp)
801051a1:	ff 45 0c             	incl   0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
801051a4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801051a8:	74 17                	je     801051c1 <strncmp+0x2b>
801051aa:	8b 45 08             	mov    0x8(%ebp),%eax
801051ad:	8a 00                	mov    (%eax),%al
801051af:	84 c0                	test   %al,%al
801051b1:	74 0e                	je     801051c1 <strncmp+0x2b>
801051b3:	8b 45 08             	mov    0x8(%ebp),%eax
801051b6:	8a 10                	mov    (%eax),%dl
801051b8:	8b 45 0c             	mov    0xc(%ebp),%eax
801051bb:	8a 00                	mov    (%eax),%al
801051bd:	38 c2                	cmp    %al,%dl
801051bf:	74 da                	je     8010519b <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
801051c1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801051c5:	75 07                	jne    801051ce <strncmp+0x38>
    return 0;
801051c7:	b8 00 00 00 00       	mov    $0x0,%eax
801051cc:	eb 14                	jmp    801051e2 <strncmp+0x4c>
  return (uchar)*p - (uchar)*q;
801051ce:	8b 45 08             	mov    0x8(%ebp),%eax
801051d1:	8a 00                	mov    (%eax),%al
801051d3:	0f b6 d0             	movzbl %al,%edx
801051d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801051d9:	8a 00                	mov    (%eax),%al
801051db:	0f b6 c0             	movzbl %al,%eax
801051de:	29 c2                	sub    %eax,%edx
801051e0:	89 d0                	mov    %edx,%eax
}
801051e2:	5d                   	pop    %ebp
801051e3:	c3                   	ret    

801051e4 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801051e4:	55                   	push   %ebp
801051e5:	89 e5                	mov    %esp,%ebp
801051e7:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801051ea:	8b 45 08             	mov    0x8(%ebp),%eax
801051ed:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801051f0:	90                   	nop
801051f1:	8b 45 10             	mov    0x10(%ebp),%eax
801051f4:	8d 50 ff             	lea    -0x1(%eax),%edx
801051f7:	89 55 10             	mov    %edx,0x10(%ebp)
801051fa:	85 c0                	test   %eax,%eax
801051fc:	7e 1c                	jle    8010521a <strncpy+0x36>
801051fe:	8b 45 08             	mov    0x8(%ebp),%eax
80105201:	8d 50 01             	lea    0x1(%eax),%edx
80105204:	89 55 08             	mov    %edx,0x8(%ebp)
80105207:	8b 55 0c             	mov    0xc(%ebp),%edx
8010520a:	8d 4a 01             	lea    0x1(%edx),%ecx
8010520d:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105210:	8a 12                	mov    (%edx),%dl
80105212:	88 10                	mov    %dl,(%eax)
80105214:	8a 00                	mov    (%eax),%al
80105216:	84 c0                	test   %al,%al
80105218:	75 d7                	jne    801051f1 <strncpy+0xd>
    ;
  while(n-- > 0)
8010521a:	eb 0c                	jmp    80105228 <strncpy+0x44>
    *s++ = 0;
8010521c:	8b 45 08             	mov    0x8(%ebp),%eax
8010521f:	8d 50 01             	lea    0x1(%eax),%edx
80105222:	89 55 08             	mov    %edx,0x8(%ebp)
80105225:	c6 00 00             	movb   $0x0,(%eax)
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105228:	8b 45 10             	mov    0x10(%ebp),%eax
8010522b:	8d 50 ff             	lea    -0x1(%eax),%edx
8010522e:	89 55 10             	mov    %edx,0x10(%ebp)
80105231:	85 c0                	test   %eax,%eax
80105233:	7f e7                	jg     8010521c <strncpy+0x38>
    *s++ = 0;
  return os;
80105235:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105238:	c9                   	leave  
80105239:	c3                   	ret    

8010523a <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
8010523a:	55                   	push   %ebp
8010523b:	89 e5                	mov    %esp,%ebp
8010523d:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105240:	8b 45 08             	mov    0x8(%ebp),%eax
80105243:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105246:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010524a:	7f 05                	jg     80105251 <safestrcpy+0x17>
    return os;
8010524c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010524f:	eb 2e                	jmp    8010527f <safestrcpy+0x45>
  while(--n > 0 && (*s++ = *t++) != 0)
80105251:	ff 4d 10             	decl   0x10(%ebp)
80105254:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105258:	7e 1c                	jle    80105276 <safestrcpy+0x3c>
8010525a:	8b 45 08             	mov    0x8(%ebp),%eax
8010525d:	8d 50 01             	lea    0x1(%eax),%edx
80105260:	89 55 08             	mov    %edx,0x8(%ebp)
80105263:	8b 55 0c             	mov    0xc(%ebp),%edx
80105266:	8d 4a 01             	lea    0x1(%edx),%ecx
80105269:	89 4d 0c             	mov    %ecx,0xc(%ebp)
8010526c:	8a 12                	mov    (%edx),%dl
8010526e:	88 10                	mov    %dl,(%eax)
80105270:	8a 00                	mov    (%eax),%al
80105272:	84 c0                	test   %al,%al
80105274:	75 db                	jne    80105251 <safestrcpy+0x17>
    ;
  *s = 0;
80105276:	8b 45 08             	mov    0x8(%ebp),%eax
80105279:	c6 00 00             	movb   $0x0,(%eax)
  return os;
8010527c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010527f:	c9                   	leave  
80105280:	c3                   	ret    

80105281 <strlen>:

int
strlen(const char *s)
{
80105281:	55                   	push   %ebp
80105282:	89 e5                	mov    %esp,%ebp
80105284:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105287:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010528e:	eb 03                	jmp    80105293 <strlen+0x12>
80105290:	ff 45 fc             	incl   -0x4(%ebp)
80105293:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105296:	8b 45 08             	mov    0x8(%ebp),%eax
80105299:	01 d0                	add    %edx,%eax
8010529b:	8a 00                	mov    (%eax),%al
8010529d:	84 c0                	test   %al,%al
8010529f:	75 ef                	jne    80105290 <strlen+0xf>
    ;
  return n;
801052a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801052a4:	c9                   	leave  
801052a5:	c3                   	ret    
	...

801052a8 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
801052a8:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801052ac:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801052b0:	55                   	push   %ebp
  pushl %ebx
801052b1:	53                   	push   %ebx
  pushl %esi
801052b2:	56                   	push   %esi
  pushl %edi
801052b3:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801052b4:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801052b6:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801052b8:	5f                   	pop    %edi
  popl %esi
801052b9:	5e                   	pop    %esi
  popl %ebx
801052ba:	5b                   	pop    %ebx
  popl %ebp
801052bb:	5d                   	pop    %ebp
  ret
801052bc:	c3                   	ret    
801052bd:	00 00                	add    %al,(%eax)
	...

801052c0 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801052c0:	55                   	push   %ebp
801052c1:	89 e5                	mov    %esp,%ebp
801052c3:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
801052c6:	e8 e4 ee ff ff       	call   801041af <myproc>
801052cb:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
801052ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052d1:	8b 00                	mov    (%eax),%eax
801052d3:	3b 45 08             	cmp    0x8(%ebp),%eax
801052d6:	76 0f                	jbe    801052e7 <fetchint+0x27>
801052d8:	8b 45 08             	mov    0x8(%ebp),%eax
801052db:	8d 50 04             	lea    0x4(%eax),%edx
801052de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052e1:	8b 00                	mov    (%eax),%eax
801052e3:	39 c2                	cmp    %eax,%edx
801052e5:	76 07                	jbe    801052ee <fetchint+0x2e>
    return -1;
801052e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052ec:	eb 0f                	jmp    801052fd <fetchint+0x3d>
  *ip = *(int*)(addr);
801052ee:	8b 45 08             	mov    0x8(%ebp),%eax
801052f1:	8b 10                	mov    (%eax),%edx
801052f3:	8b 45 0c             	mov    0xc(%ebp),%eax
801052f6:	89 10                	mov    %edx,(%eax)
  return 0;
801052f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801052fd:	c9                   	leave  
801052fe:	c3                   	ret    

801052ff <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801052ff:	55                   	push   %ebp
80105300:	89 e5                	mov    %esp,%ebp
80105302:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80105305:	e8 a5 ee ff ff       	call   801041af <myproc>
8010530a:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
8010530d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105310:	8b 00                	mov    (%eax),%eax
80105312:	3b 45 08             	cmp    0x8(%ebp),%eax
80105315:	77 07                	ja     8010531e <fetchstr+0x1f>
    return -1;
80105317:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010531c:	eb 41                	jmp    8010535f <fetchstr+0x60>
  *pp = (char*)addr;
8010531e:	8b 55 08             	mov    0x8(%ebp),%edx
80105321:	8b 45 0c             	mov    0xc(%ebp),%eax
80105324:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80105326:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105329:	8b 00                	mov    (%eax),%eax
8010532b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
8010532e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105331:	8b 00                	mov    (%eax),%eax
80105333:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105336:	eb 1a                	jmp    80105352 <fetchstr+0x53>
    if(*s == 0)
80105338:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010533b:	8a 00                	mov    (%eax),%al
8010533d:	84 c0                	test   %al,%al
8010533f:	75 0e                	jne    8010534f <fetchstr+0x50>
      return s - *pp;
80105341:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105344:	8b 45 0c             	mov    0xc(%ebp),%eax
80105347:	8b 00                	mov    (%eax),%eax
80105349:	29 c2                	sub    %eax,%edx
8010534b:	89 d0                	mov    %edx,%eax
8010534d:	eb 10                	jmp    8010535f <fetchstr+0x60>

  if(addr >= curproc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)curproc->sz;
  for(s = *pp; s < ep; s++){
8010534f:	ff 45 f4             	incl   -0xc(%ebp)
80105352:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105355:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80105358:	72 de                	jb     80105338 <fetchstr+0x39>
    if(*s == 0)
      return s - *pp;
  }
  return -1;
8010535a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010535f:	c9                   	leave  
80105360:	c3                   	ret    

80105361 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105361:	55                   	push   %ebp
80105362:	89 e5                	mov    %esp,%ebp
80105364:	83 ec 18             	sub    $0x18,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105367:	e8 43 ee ff ff       	call   801041af <myproc>
8010536c:	8b 40 18             	mov    0x18(%eax),%eax
8010536f:	8b 50 44             	mov    0x44(%eax),%edx
80105372:	8b 45 08             	mov    0x8(%ebp),%eax
80105375:	c1 e0 02             	shl    $0x2,%eax
80105378:	01 d0                	add    %edx,%eax
8010537a:	8d 50 04             	lea    0x4(%eax),%edx
8010537d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105380:	89 44 24 04          	mov    %eax,0x4(%esp)
80105384:	89 14 24             	mov    %edx,(%esp)
80105387:	e8 34 ff ff ff       	call   801052c0 <fetchint>
}
8010538c:	c9                   	leave  
8010538d:	c3                   	ret    

8010538e <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
8010538e:	55                   	push   %ebp
8010538f:	89 e5                	mov    %esp,%ebp
80105391:	83 ec 28             	sub    $0x28,%esp
  int i;
  struct proc *curproc = myproc();
80105394:	e8 16 ee ff ff       	call   801041af <myproc>
80105399:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
8010539c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010539f:	89 44 24 04          	mov    %eax,0x4(%esp)
801053a3:	8b 45 08             	mov    0x8(%ebp),%eax
801053a6:	89 04 24             	mov    %eax,(%esp)
801053a9:	e8 b3 ff ff ff       	call   80105361 <argint>
801053ae:	85 c0                	test   %eax,%eax
801053b0:	79 07                	jns    801053b9 <argptr+0x2b>
    return -1;
801053b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053b7:	eb 3d                	jmp    801053f6 <argptr+0x68>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
801053b9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801053bd:	78 21                	js     801053e0 <argptr+0x52>
801053bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053c2:	89 c2                	mov    %eax,%edx
801053c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053c7:	8b 00                	mov    (%eax),%eax
801053c9:	39 c2                	cmp    %eax,%edx
801053cb:	73 13                	jae    801053e0 <argptr+0x52>
801053cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053d0:	89 c2                	mov    %eax,%edx
801053d2:	8b 45 10             	mov    0x10(%ebp),%eax
801053d5:	01 c2                	add    %eax,%edx
801053d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053da:	8b 00                	mov    (%eax),%eax
801053dc:	39 c2                	cmp    %eax,%edx
801053de:	76 07                	jbe    801053e7 <argptr+0x59>
    return -1;
801053e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053e5:	eb 0f                	jmp    801053f6 <argptr+0x68>
  *pp = (char*)i;
801053e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053ea:	89 c2                	mov    %eax,%edx
801053ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801053ef:	89 10                	mov    %edx,(%eax)
  return 0;
801053f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801053f6:	c9                   	leave  
801053f7:	c3                   	ret    

801053f8 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801053f8:	55                   	push   %ebp
801053f9:	89 e5                	mov    %esp,%ebp
801053fb:	83 ec 28             	sub    $0x28,%esp
  int addr;
  if(argint(n, &addr) < 0)
801053fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105401:	89 44 24 04          	mov    %eax,0x4(%esp)
80105405:	8b 45 08             	mov    0x8(%ebp),%eax
80105408:	89 04 24             	mov    %eax,(%esp)
8010540b:	e8 51 ff ff ff       	call   80105361 <argint>
80105410:	85 c0                	test   %eax,%eax
80105412:	79 07                	jns    8010541b <argstr+0x23>
    return -1;
80105414:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105419:	eb 12                	jmp    8010542d <argstr+0x35>
  return fetchstr(addr, pp);
8010541b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010541e:	8b 55 0c             	mov    0xc(%ebp),%edx
80105421:	89 54 24 04          	mov    %edx,0x4(%esp)
80105425:	89 04 24             	mov    %eax,(%esp)
80105428:	e8 d2 fe ff ff       	call   801052ff <fetchstr>
}
8010542d:	c9                   	leave  
8010542e:	c3                   	ret    

8010542f <syscall>:
[SYS_set_curr_proc] sys_set_curr_proc,
};

void
syscall(void)
{
8010542f:	55                   	push   %ebp
80105430:	89 e5                	mov    %esp,%ebp
80105432:	53                   	push   %ebx
80105433:	83 ec 24             	sub    $0x24,%esp
  int num;
  struct proc *curproc = myproc();
80105436:	e8 74 ed ff ff       	call   801041af <myproc>
8010543b:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
8010543e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105441:	8b 40 18             	mov    0x18(%eax),%eax
80105444:	8b 40 1c             	mov    0x1c(%eax),%eax
80105447:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
8010544a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010544e:	7e 2d                	jle    8010547d <syscall+0x4e>
80105450:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105453:	83 f8 24             	cmp    $0x24,%eax
80105456:	77 25                	ja     8010547d <syscall+0x4e>
80105458:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010545b:	8b 04 85 20 b0 10 80 	mov    -0x7fef4fe0(,%eax,4),%eax
80105462:	85 c0                	test   %eax,%eax
80105464:	74 17                	je     8010547d <syscall+0x4e>
    curproc->tf->eax = syscalls[num]();
80105466:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105469:	8b 58 18             	mov    0x18(%eax),%ebx
8010546c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010546f:	8b 04 85 20 b0 10 80 	mov    -0x7fef4fe0(,%eax,4),%eax
80105476:	ff d0                	call   *%eax
80105478:	89 43 1c             	mov    %eax,0x1c(%ebx)
8010547b:	eb 34                	jmp    801054b1 <syscall+0x82>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
8010547d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105480:	8d 48 6c             	lea    0x6c(%eax),%ecx

  num = curproc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    curproc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105483:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105486:	8b 40 10             	mov    0x10(%eax),%eax
80105489:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010548c:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105490:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105494:	89 44 24 04          	mov    %eax,0x4(%esp)
80105498:	c7 04 24 2c 8c 10 80 	movl   $0x80108c2c,(%esp)
8010549f:	e8 1d af ff ff       	call   801003c1 <cprintf>
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
801054a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054a7:	8b 40 18             	mov    0x18(%eax),%eax
801054aa:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801054b1:	83 c4 24             	add    $0x24,%esp
801054b4:	5b                   	pop    %ebx
801054b5:	5d                   	pop    %ebp
801054b6:	c3                   	ret    
	...

801054b8 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801054b8:	55                   	push   %ebp
801054b9:	89 e5                	mov    %esp,%ebp
801054bb:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801054be:	8d 45 f0             	lea    -0x10(%ebp),%eax
801054c1:	89 44 24 04          	mov    %eax,0x4(%esp)
801054c5:	8b 45 08             	mov    0x8(%ebp),%eax
801054c8:	89 04 24             	mov    %eax,(%esp)
801054cb:	e8 91 fe ff ff       	call   80105361 <argint>
801054d0:	85 c0                	test   %eax,%eax
801054d2:	79 07                	jns    801054db <argfd+0x23>
    return -1;
801054d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054d9:	eb 4f                	jmp    8010552a <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
801054db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054de:	85 c0                	test   %eax,%eax
801054e0:	78 20                	js     80105502 <argfd+0x4a>
801054e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054e5:	83 f8 0f             	cmp    $0xf,%eax
801054e8:	7f 18                	jg     80105502 <argfd+0x4a>
801054ea:	e8 c0 ec ff ff       	call   801041af <myproc>
801054ef:	8b 55 f0             	mov    -0x10(%ebp),%edx
801054f2:	83 c2 08             	add    $0x8,%edx
801054f5:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801054f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801054fc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105500:	75 07                	jne    80105509 <argfd+0x51>
    return -1;
80105502:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105507:	eb 21                	jmp    8010552a <argfd+0x72>
  if(pfd)
80105509:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010550d:	74 08                	je     80105517 <argfd+0x5f>
    *pfd = fd;
8010550f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105512:	8b 45 0c             	mov    0xc(%ebp),%eax
80105515:	89 10                	mov    %edx,(%eax)
  if(pf)
80105517:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010551b:	74 08                	je     80105525 <argfd+0x6d>
    *pf = f;
8010551d:	8b 45 10             	mov    0x10(%ebp),%eax
80105520:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105523:	89 10                	mov    %edx,(%eax)
  return 0;
80105525:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010552a:	c9                   	leave  
8010552b:	c3                   	ret    

8010552c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
8010552c:	55                   	push   %ebp
8010552d:	89 e5                	mov    %esp,%ebp
8010552f:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105532:	e8 78 ec ff ff       	call   801041af <myproc>
80105537:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
8010553a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105541:	eb 29                	jmp    8010556c <fdalloc+0x40>
    if(curproc->ofile[fd] == 0){
80105543:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105546:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105549:	83 c2 08             	add    $0x8,%edx
8010554c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105550:	85 c0                	test   %eax,%eax
80105552:	75 15                	jne    80105569 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80105554:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105557:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010555a:	8d 4a 08             	lea    0x8(%edx),%ecx
8010555d:	8b 55 08             	mov    0x8(%ebp),%edx
80105560:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105564:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105567:	eb 0e                	jmp    80105577 <fdalloc+0x4b>
fdalloc(struct file *f)
{
  int fd;
  struct proc *curproc = myproc();

  for(fd = 0; fd < NOFILE; fd++){
80105569:	ff 45 f4             	incl   -0xc(%ebp)
8010556c:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105570:	7e d1                	jle    80105543 <fdalloc+0x17>
    if(curproc->ofile[fd] == 0){
      curproc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105572:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105577:	c9                   	leave  
80105578:	c3                   	ret    

80105579 <sys_dup>:

int
sys_dup(void)
{
80105579:	55                   	push   %ebp
8010557a:	89 e5                	mov    %esp,%ebp
8010557c:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
8010557f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105582:	89 44 24 08          	mov    %eax,0x8(%esp)
80105586:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010558d:	00 
8010558e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105595:	e8 1e ff ff ff       	call   801054b8 <argfd>
8010559a:	85 c0                	test   %eax,%eax
8010559c:	79 07                	jns    801055a5 <sys_dup+0x2c>
    return -1;
8010559e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055a3:	eb 29                	jmp    801055ce <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801055a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055a8:	89 04 24             	mov    %eax,(%esp)
801055ab:	e8 7c ff ff ff       	call   8010552c <fdalloc>
801055b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801055b3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801055b7:	79 07                	jns    801055c0 <sys_dup+0x47>
    return -1;
801055b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055be:	eb 0e                	jmp    801055ce <sys_dup+0x55>
  filedup(f);
801055c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055c3:	89 04 24             	mov    %eax,(%esp)
801055c6:	e8 91 ba ff ff       	call   8010105c <filedup>
  return fd;
801055cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801055ce:	c9                   	leave  
801055cf:	c3                   	ret    

801055d0 <sys_read>:

int
sys_read(void)
{
801055d0:	55                   	push   %ebp
801055d1:	89 e5                	mov    %esp,%ebp
801055d3:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801055d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
801055d9:	89 44 24 08          	mov    %eax,0x8(%esp)
801055dd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801055e4:	00 
801055e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801055ec:	e8 c7 fe ff ff       	call   801054b8 <argfd>
801055f1:	85 c0                	test   %eax,%eax
801055f3:	78 35                	js     8010562a <sys_read+0x5a>
801055f5:	8d 45 f0             	lea    -0x10(%ebp),%eax
801055f8:	89 44 24 04          	mov    %eax,0x4(%esp)
801055fc:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105603:	e8 59 fd ff ff       	call   80105361 <argint>
80105608:	85 c0                	test   %eax,%eax
8010560a:	78 1e                	js     8010562a <sys_read+0x5a>
8010560c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010560f:	89 44 24 08          	mov    %eax,0x8(%esp)
80105613:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105616:	89 44 24 04          	mov    %eax,0x4(%esp)
8010561a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105621:	e8 68 fd ff ff       	call   8010538e <argptr>
80105626:	85 c0                	test   %eax,%eax
80105628:	79 07                	jns    80105631 <sys_read+0x61>
    return -1;
8010562a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010562f:	eb 19                	jmp    8010564a <sys_read+0x7a>
  return fileread(f, p, n);
80105631:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105634:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105637:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010563a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010563e:	89 54 24 04          	mov    %edx,0x4(%esp)
80105642:	89 04 24             	mov    %eax,(%esp)
80105645:	e8 73 bb ff ff       	call   801011bd <fileread>
}
8010564a:	c9                   	leave  
8010564b:	c3                   	ret    

8010564c <sys_write>:

int
sys_write(void)
{
8010564c:	55                   	push   %ebp
8010564d:	89 e5                	mov    %esp,%ebp
8010564f:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105652:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105655:	89 44 24 08          	mov    %eax,0x8(%esp)
80105659:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105660:	00 
80105661:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105668:	e8 4b fe ff ff       	call   801054b8 <argfd>
8010566d:	85 c0                	test   %eax,%eax
8010566f:	78 35                	js     801056a6 <sys_write+0x5a>
80105671:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105674:	89 44 24 04          	mov    %eax,0x4(%esp)
80105678:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010567f:	e8 dd fc ff ff       	call   80105361 <argint>
80105684:	85 c0                	test   %eax,%eax
80105686:	78 1e                	js     801056a6 <sys_write+0x5a>
80105688:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010568b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010568f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105692:	89 44 24 04          	mov    %eax,0x4(%esp)
80105696:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010569d:	e8 ec fc ff ff       	call   8010538e <argptr>
801056a2:	85 c0                	test   %eax,%eax
801056a4:	79 07                	jns    801056ad <sys_write+0x61>
    return -1;
801056a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056ab:	eb 19                	jmp    801056c6 <sys_write+0x7a>
  return filewrite(f, p, n);
801056ad:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801056b0:	8b 55 ec             	mov    -0x14(%ebp),%edx
801056b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056b6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801056ba:	89 54 24 04          	mov    %edx,0x4(%esp)
801056be:	89 04 24             	mov    %eax,(%esp)
801056c1:	e8 b2 bb ff ff       	call   80101278 <filewrite>
}
801056c6:	c9                   	leave  
801056c7:	c3                   	ret    

801056c8 <sys_close>:

int
sys_close(void)
{
801056c8:	55                   	push   %ebp
801056c9:	89 e5                	mov    %esp,%ebp
801056cb:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
801056ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
801056d1:	89 44 24 08          	mov    %eax,0x8(%esp)
801056d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
801056d8:	89 44 24 04          	mov    %eax,0x4(%esp)
801056dc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801056e3:	e8 d0 fd ff ff       	call   801054b8 <argfd>
801056e8:	85 c0                	test   %eax,%eax
801056ea:	79 07                	jns    801056f3 <sys_close+0x2b>
    return -1;
801056ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056f1:	eb 23                	jmp    80105716 <sys_close+0x4e>
  myproc()->ofile[fd] = 0;
801056f3:	e8 b7 ea ff ff       	call   801041af <myproc>
801056f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801056fb:	83 c2 08             	add    $0x8,%edx
801056fe:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105705:	00 
  fileclose(f);
80105706:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105709:	89 04 24             	mov    %eax,(%esp)
8010570c:	e8 93 b9 ff ff       	call   801010a4 <fileclose>
  return 0;
80105711:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105716:	c9                   	leave  
80105717:	c3                   	ret    

80105718 <sys_fstat>:

int
sys_fstat(void)
{
80105718:	55                   	push   %ebp
80105719:	89 e5                	mov    %esp,%ebp
8010571b:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010571e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105721:	89 44 24 08          	mov    %eax,0x8(%esp)
80105725:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010572c:	00 
8010572d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105734:	e8 7f fd ff ff       	call   801054b8 <argfd>
80105739:	85 c0                	test   %eax,%eax
8010573b:	78 1f                	js     8010575c <sys_fstat+0x44>
8010573d:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105744:	00 
80105745:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105748:	89 44 24 04          	mov    %eax,0x4(%esp)
8010574c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105753:	e8 36 fc ff ff       	call   8010538e <argptr>
80105758:	85 c0                	test   %eax,%eax
8010575a:	79 07                	jns    80105763 <sys_fstat+0x4b>
    return -1;
8010575c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105761:	eb 12                	jmp    80105775 <sys_fstat+0x5d>
  return filestat(f, st);
80105763:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105766:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105769:	89 54 24 04          	mov    %edx,0x4(%esp)
8010576d:	89 04 24             	mov    %eax,(%esp)
80105770:	e8 f9 b9 ff ff       	call   8010116e <filestat>
}
80105775:	c9                   	leave  
80105776:	c3                   	ret    

80105777 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105777:	55                   	push   %ebp
80105778:	89 e5                	mov    %esp,%ebp
8010577a:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010577d:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105780:	89 44 24 04          	mov    %eax,0x4(%esp)
80105784:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010578b:	e8 68 fc ff ff       	call   801053f8 <argstr>
80105790:	85 c0                	test   %eax,%eax
80105792:	78 17                	js     801057ab <sys_link+0x34>
80105794:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105797:	89 44 24 04          	mov    %eax,0x4(%esp)
8010579b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801057a2:	e8 51 fc ff ff       	call   801053f8 <argstr>
801057a7:	85 c0                	test   %eax,%eax
801057a9:	79 0a                	jns    801057b5 <sys_link+0x3e>
    return -1;
801057ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057b0:	e9 3d 01 00 00       	jmp    801058f2 <sys_link+0x17b>

  begin_op();
801057b5:	e8 fd dc ff ff       	call   801034b7 <begin_op>
  if((ip = namei(old)) == 0){
801057ba:	8b 45 d8             	mov    -0x28(%ebp),%eax
801057bd:	89 04 24             	mov    %eax,(%esp)
801057c0:	e8 1e cd ff ff       	call   801024e3 <namei>
801057c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801057c8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801057cc:	75 0f                	jne    801057dd <sys_link+0x66>
    end_op();
801057ce:	e8 66 dd ff ff       	call   80103539 <end_op>
    return -1;
801057d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057d8:	e9 15 01 00 00       	jmp    801058f2 <sys_link+0x17b>
  }

  ilock(ip);
801057dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057e0:	89 04 24             	mov    %eax,(%esp)
801057e3:	e8 d6 c1 ff ff       	call   801019be <ilock>
  if(ip->type == T_DIR){
801057e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057eb:	8b 40 50             	mov    0x50(%eax),%eax
801057ee:	66 83 f8 01          	cmp    $0x1,%ax
801057f2:	75 1a                	jne    8010580e <sys_link+0x97>
    iunlockput(ip);
801057f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057f7:	89 04 24             	mov    %eax,(%esp)
801057fa:	e8 be c3 ff ff       	call   80101bbd <iunlockput>
    end_op();
801057ff:	e8 35 dd ff ff       	call   80103539 <end_op>
    return -1;
80105804:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105809:	e9 e4 00 00 00       	jmp    801058f2 <sys_link+0x17b>
  }

  ip->nlink++;
8010580e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105811:	66 8b 40 56          	mov    0x56(%eax),%ax
80105815:	40                   	inc    %eax
80105816:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105819:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
8010581d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105820:	89 04 24             	mov    %eax,(%esp)
80105823:	e8 d3 bf ff ff       	call   801017fb <iupdate>
  iunlock(ip);
80105828:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010582b:	89 04 24             	mov    %eax,(%esp)
8010582e:	e8 95 c2 ff ff       	call   80101ac8 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105833:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105836:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105839:	89 54 24 04          	mov    %edx,0x4(%esp)
8010583d:	89 04 24             	mov    %eax,(%esp)
80105840:	e8 c0 cc ff ff       	call   80102505 <nameiparent>
80105845:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105848:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010584c:	75 02                	jne    80105850 <sys_link+0xd9>
    goto bad;
8010584e:	eb 68                	jmp    801058b8 <sys_link+0x141>
  ilock(dp);
80105850:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105853:	89 04 24             	mov    %eax,(%esp)
80105856:	e8 63 c1 ff ff       	call   801019be <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
8010585b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010585e:	8b 10                	mov    (%eax),%edx
80105860:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105863:	8b 00                	mov    (%eax),%eax
80105865:	39 c2                	cmp    %eax,%edx
80105867:	75 20                	jne    80105889 <sys_link+0x112>
80105869:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010586c:	8b 40 04             	mov    0x4(%eax),%eax
8010586f:	89 44 24 08          	mov    %eax,0x8(%esp)
80105873:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105876:	89 44 24 04          	mov    %eax,0x4(%esp)
8010587a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010587d:	89 04 24             	mov    %eax,(%esp)
80105880:	e8 ab c9 ff ff       	call   80102230 <dirlink>
80105885:	85 c0                	test   %eax,%eax
80105887:	79 0d                	jns    80105896 <sys_link+0x11f>
    iunlockput(dp);
80105889:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010588c:	89 04 24             	mov    %eax,(%esp)
8010588f:	e8 29 c3 ff ff       	call   80101bbd <iunlockput>
    goto bad;
80105894:	eb 22                	jmp    801058b8 <sys_link+0x141>
  }
  iunlockput(dp);
80105896:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105899:	89 04 24             	mov    %eax,(%esp)
8010589c:	e8 1c c3 ff ff       	call   80101bbd <iunlockput>
  iput(ip);
801058a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058a4:	89 04 24             	mov    %eax,(%esp)
801058a7:	e8 60 c2 ff ff       	call   80101b0c <iput>

  end_op();
801058ac:	e8 88 dc ff ff       	call   80103539 <end_op>

  return 0;
801058b1:	b8 00 00 00 00       	mov    $0x0,%eax
801058b6:	eb 3a                	jmp    801058f2 <sys_link+0x17b>

bad:
  ilock(ip);
801058b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058bb:	89 04 24             	mov    %eax,(%esp)
801058be:	e8 fb c0 ff ff       	call   801019be <ilock>
  ip->nlink--;
801058c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058c6:	66 8b 40 56          	mov    0x56(%eax),%ax
801058ca:	48                   	dec    %eax
801058cb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801058ce:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
801058d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058d5:	89 04 24             	mov    %eax,(%esp)
801058d8:	e8 1e bf ff ff       	call   801017fb <iupdate>
  iunlockput(ip);
801058dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058e0:	89 04 24             	mov    %eax,(%esp)
801058e3:	e8 d5 c2 ff ff       	call   80101bbd <iunlockput>
  end_op();
801058e8:	e8 4c dc ff ff       	call   80103539 <end_op>
  return -1;
801058ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801058f2:	c9                   	leave  
801058f3:	c3                   	ret    

801058f4 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801058f4:	55                   	push   %ebp
801058f5:	89 e5                	mov    %esp,%ebp
801058f7:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801058fa:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105901:	eb 4a                	jmp    8010594d <isdirempty+0x59>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105903:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105906:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010590d:	00 
8010590e:	89 44 24 08          	mov    %eax,0x8(%esp)
80105912:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105915:	89 44 24 04          	mov    %eax,0x4(%esp)
80105919:	8b 45 08             	mov    0x8(%ebp),%eax
8010591c:	89 04 24             	mov    %eax,(%esp)
8010591f:	e8 31 c5 ff ff       	call   80101e55 <readi>
80105924:	83 f8 10             	cmp    $0x10,%eax
80105927:	74 0c                	je     80105935 <isdirempty+0x41>
      panic("isdirempty: readi");
80105929:	c7 04 24 48 8c 10 80 	movl   $0x80108c48,(%esp)
80105930:	e8 1f ac ff ff       	call   80100554 <panic>
    if(de.inum != 0)
80105935:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105938:	66 85 c0             	test   %ax,%ax
8010593b:	74 07                	je     80105944 <isdirempty+0x50>
      return 0;
8010593d:	b8 00 00 00 00       	mov    $0x0,%eax
80105942:	eb 1b                	jmp    8010595f <isdirempty+0x6b>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105944:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105947:	83 c0 10             	add    $0x10,%eax
8010594a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010594d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105950:	8b 45 08             	mov    0x8(%ebp),%eax
80105953:	8b 40 58             	mov    0x58(%eax),%eax
80105956:	39 c2                	cmp    %eax,%edx
80105958:	72 a9                	jb     80105903 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
8010595a:	b8 01 00 00 00       	mov    $0x1,%eax
}
8010595f:	c9                   	leave  
80105960:	c3                   	ret    

80105961 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105961:	55                   	push   %ebp
80105962:	89 e5                	mov    %esp,%ebp
80105964:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105967:	8d 45 cc             	lea    -0x34(%ebp),%eax
8010596a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010596e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105975:	e8 7e fa ff ff       	call   801053f8 <argstr>
8010597a:	85 c0                	test   %eax,%eax
8010597c:	79 0a                	jns    80105988 <sys_unlink+0x27>
    return -1;
8010597e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105983:	e9 a9 01 00 00       	jmp    80105b31 <sys_unlink+0x1d0>

  begin_op();
80105988:	e8 2a db ff ff       	call   801034b7 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
8010598d:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105990:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105993:	89 54 24 04          	mov    %edx,0x4(%esp)
80105997:	89 04 24             	mov    %eax,(%esp)
8010599a:	e8 66 cb ff ff       	call   80102505 <nameiparent>
8010599f:	89 45 f4             	mov    %eax,-0xc(%ebp)
801059a2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801059a6:	75 0f                	jne    801059b7 <sys_unlink+0x56>
    end_op();
801059a8:	e8 8c db ff ff       	call   80103539 <end_op>
    return -1;
801059ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059b2:	e9 7a 01 00 00       	jmp    80105b31 <sys_unlink+0x1d0>
  }

  ilock(dp);
801059b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059ba:	89 04 24             	mov    %eax,(%esp)
801059bd:	e8 fc bf ff ff       	call   801019be <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801059c2:	c7 44 24 04 5a 8c 10 	movl   $0x80108c5a,0x4(%esp)
801059c9:	80 
801059ca:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801059cd:	89 04 24             	mov    %eax,(%esp)
801059d0:	e8 73 c7 ff ff       	call   80102148 <namecmp>
801059d5:	85 c0                	test   %eax,%eax
801059d7:	0f 84 3f 01 00 00    	je     80105b1c <sys_unlink+0x1bb>
801059dd:	c7 44 24 04 5c 8c 10 	movl   $0x80108c5c,0x4(%esp)
801059e4:	80 
801059e5:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801059e8:	89 04 24             	mov    %eax,(%esp)
801059eb:	e8 58 c7 ff ff       	call   80102148 <namecmp>
801059f0:	85 c0                	test   %eax,%eax
801059f2:	0f 84 24 01 00 00    	je     80105b1c <sys_unlink+0x1bb>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
801059f8:	8d 45 c8             	lea    -0x38(%ebp),%eax
801059fb:	89 44 24 08          	mov    %eax,0x8(%esp)
801059ff:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105a02:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a09:	89 04 24             	mov    %eax,(%esp)
80105a0c:	e8 59 c7 ff ff       	call   8010216a <dirlookup>
80105a11:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105a14:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105a18:	75 05                	jne    80105a1f <sys_unlink+0xbe>
    goto bad;
80105a1a:	e9 fd 00 00 00       	jmp    80105b1c <sys_unlink+0x1bb>
  ilock(ip);
80105a1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a22:	89 04 24             	mov    %eax,(%esp)
80105a25:	e8 94 bf ff ff       	call   801019be <ilock>

  if(ip->nlink < 1)
80105a2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a2d:	66 8b 40 56          	mov    0x56(%eax),%ax
80105a31:	66 85 c0             	test   %ax,%ax
80105a34:	7f 0c                	jg     80105a42 <sys_unlink+0xe1>
    panic("unlink: nlink < 1");
80105a36:	c7 04 24 5f 8c 10 80 	movl   $0x80108c5f,(%esp)
80105a3d:	e8 12 ab ff ff       	call   80100554 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105a42:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a45:	8b 40 50             	mov    0x50(%eax),%eax
80105a48:	66 83 f8 01          	cmp    $0x1,%ax
80105a4c:	75 1f                	jne    80105a6d <sys_unlink+0x10c>
80105a4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a51:	89 04 24             	mov    %eax,(%esp)
80105a54:	e8 9b fe ff ff       	call   801058f4 <isdirempty>
80105a59:	85 c0                	test   %eax,%eax
80105a5b:	75 10                	jne    80105a6d <sys_unlink+0x10c>
    iunlockput(ip);
80105a5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a60:	89 04 24             	mov    %eax,(%esp)
80105a63:	e8 55 c1 ff ff       	call   80101bbd <iunlockput>
    goto bad;
80105a68:	e9 af 00 00 00       	jmp    80105b1c <sys_unlink+0x1bb>
  }

  memset(&de, 0, sizeof(de));
80105a6d:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105a74:	00 
80105a75:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105a7c:	00 
80105a7d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105a80:	89 04 24             	mov    %eax,(%esp)
80105a83:	e8 a6 f5 ff ff       	call   8010502e <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105a88:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105a8b:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105a92:	00 
80105a93:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a97:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105a9a:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aa1:	89 04 24             	mov    %eax,(%esp)
80105aa4:	e8 10 c5 ff ff       	call   80101fb9 <writei>
80105aa9:	83 f8 10             	cmp    $0x10,%eax
80105aac:	74 0c                	je     80105aba <sys_unlink+0x159>
    panic("unlink: writei");
80105aae:	c7 04 24 71 8c 10 80 	movl   $0x80108c71,(%esp)
80105ab5:	e8 9a aa ff ff       	call   80100554 <panic>
  if(ip->type == T_DIR){
80105aba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105abd:	8b 40 50             	mov    0x50(%eax),%eax
80105ac0:	66 83 f8 01          	cmp    $0x1,%ax
80105ac4:	75 1a                	jne    80105ae0 <sys_unlink+0x17f>
    dp->nlink--;
80105ac6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ac9:	66 8b 40 56          	mov    0x56(%eax),%ax
80105acd:	48                   	dec    %eax
80105ace:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ad1:	66 89 42 56          	mov    %ax,0x56(%edx)
    iupdate(dp);
80105ad5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ad8:	89 04 24             	mov    %eax,(%esp)
80105adb:	e8 1b bd ff ff       	call   801017fb <iupdate>
  }
  iunlockput(dp);
80105ae0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ae3:	89 04 24             	mov    %eax,(%esp)
80105ae6:	e8 d2 c0 ff ff       	call   80101bbd <iunlockput>

  ip->nlink--;
80105aeb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105aee:	66 8b 40 56          	mov    0x56(%eax),%ax
80105af2:	48                   	dec    %eax
80105af3:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105af6:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
80105afa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105afd:	89 04 24             	mov    %eax,(%esp)
80105b00:	e8 f6 bc ff ff       	call   801017fb <iupdate>
  iunlockput(ip);
80105b05:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b08:	89 04 24             	mov    %eax,(%esp)
80105b0b:	e8 ad c0 ff ff       	call   80101bbd <iunlockput>

  end_op();
80105b10:	e8 24 da ff ff       	call   80103539 <end_op>

  return 0;
80105b15:	b8 00 00 00 00       	mov    $0x0,%eax
80105b1a:	eb 15                	jmp    80105b31 <sys_unlink+0x1d0>

bad:
  iunlockput(dp);
80105b1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b1f:	89 04 24             	mov    %eax,(%esp)
80105b22:	e8 96 c0 ff ff       	call   80101bbd <iunlockput>
  end_op();
80105b27:	e8 0d da ff ff       	call   80103539 <end_op>
  return -1;
80105b2c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b31:	c9                   	leave  
80105b32:	c3                   	ret    

80105b33 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105b33:	55                   	push   %ebp
80105b34:	89 e5                	mov    %esp,%ebp
80105b36:	83 ec 48             	sub    $0x48,%esp
80105b39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105b3c:	8b 55 10             	mov    0x10(%ebp),%edx
80105b3f:	8b 45 14             	mov    0x14(%ebp),%eax
80105b42:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105b46:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105b4a:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105b4e:	8d 45 de             	lea    -0x22(%ebp),%eax
80105b51:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b55:	8b 45 08             	mov    0x8(%ebp),%eax
80105b58:	89 04 24             	mov    %eax,(%esp)
80105b5b:	e8 a5 c9 ff ff       	call   80102505 <nameiparent>
80105b60:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b63:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b67:	75 0a                	jne    80105b73 <create+0x40>
    return 0;
80105b69:	b8 00 00 00 00       	mov    $0x0,%eax
80105b6e:	e9 79 01 00 00       	jmp    80105cec <create+0x1b9>
  ilock(dp);
80105b73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b76:	89 04 24             	mov    %eax,(%esp)
80105b79:	e8 40 be ff ff       	call   801019be <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80105b7e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105b81:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b85:	8d 45 de             	lea    -0x22(%ebp),%eax
80105b88:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b8f:	89 04 24             	mov    %eax,(%esp)
80105b92:	e8 d3 c5 ff ff       	call   8010216a <dirlookup>
80105b97:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b9a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b9e:	74 46                	je     80105be6 <create+0xb3>
    iunlockput(dp);
80105ba0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ba3:	89 04 24             	mov    %eax,(%esp)
80105ba6:	e8 12 c0 ff ff       	call   80101bbd <iunlockput>
    ilock(ip);
80105bab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bae:	89 04 24             	mov    %eax,(%esp)
80105bb1:	e8 08 be ff ff       	call   801019be <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80105bb6:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105bbb:	75 14                	jne    80105bd1 <create+0x9e>
80105bbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bc0:	8b 40 50             	mov    0x50(%eax),%eax
80105bc3:	66 83 f8 02          	cmp    $0x2,%ax
80105bc7:	75 08                	jne    80105bd1 <create+0x9e>
      return ip;
80105bc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bcc:	e9 1b 01 00 00       	jmp    80105cec <create+0x1b9>
    iunlockput(ip);
80105bd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bd4:	89 04 24             	mov    %eax,(%esp)
80105bd7:	e8 e1 bf ff ff       	call   80101bbd <iunlockput>
    return 0;
80105bdc:	b8 00 00 00 00       	mov    $0x0,%eax
80105be1:	e9 06 01 00 00       	jmp    80105cec <create+0x1b9>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105be6:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105bea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bed:	8b 00                	mov    (%eax),%eax
80105bef:	89 54 24 04          	mov    %edx,0x4(%esp)
80105bf3:	89 04 24             	mov    %eax,(%esp)
80105bf6:	e8 2e bb ff ff       	call   80101729 <ialloc>
80105bfb:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105bfe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c02:	75 0c                	jne    80105c10 <create+0xdd>
    panic("create: ialloc");
80105c04:	c7 04 24 80 8c 10 80 	movl   $0x80108c80,(%esp)
80105c0b:	e8 44 a9 ff ff       	call   80100554 <panic>

  ilock(ip);
80105c10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c13:	89 04 24             	mov    %eax,(%esp)
80105c16:	e8 a3 bd ff ff       	call   801019be <ilock>
  ip->major = major;
80105c1b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105c1e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80105c21:	66 89 42 52          	mov    %ax,0x52(%edx)
  ip->minor = minor;
80105c25:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105c28:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105c2b:	66 89 42 54          	mov    %ax,0x54(%edx)
  ip->nlink = 1;
80105c2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c32:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105c38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c3b:	89 04 24             	mov    %eax,(%esp)
80105c3e:	e8 b8 bb ff ff       	call   801017fb <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80105c43:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105c48:	75 68                	jne    80105cb2 <create+0x17f>
    dp->nlink++;  // for ".."
80105c4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c4d:	66 8b 40 56          	mov    0x56(%eax),%ax
80105c51:	40                   	inc    %eax
80105c52:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c55:	66 89 42 56          	mov    %ax,0x56(%edx)
    iupdate(dp);
80105c59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c5c:	89 04 24             	mov    %eax,(%esp)
80105c5f:	e8 97 bb ff ff       	call   801017fb <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105c64:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c67:	8b 40 04             	mov    0x4(%eax),%eax
80105c6a:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c6e:	c7 44 24 04 5a 8c 10 	movl   $0x80108c5a,0x4(%esp)
80105c75:	80 
80105c76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c79:	89 04 24             	mov    %eax,(%esp)
80105c7c:	e8 af c5 ff ff       	call   80102230 <dirlink>
80105c81:	85 c0                	test   %eax,%eax
80105c83:	78 21                	js     80105ca6 <create+0x173>
80105c85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c88:	8b 40 04             	mov    0x4(%eax),%eax
80105c8b:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c8f:	c7 44 24 04 5c 8c 10 	movl   $0x80108c5c,0x4(%esp)
80105c96:	80 
80105c97:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c9a:	89 04 24             	mov    %eax,(%esp)
80105c9d:	e8 8e c5 ff ff       	call   80102230 <dirlink>
80105ca2:	85 c0                	test   %eax,%eax
80105ca4:	79 0c                	jns    80105cb2 <create+0x17f>
      panic("create dots");
80105ca6:	c7 04 24 8f 8c 10 80 	movl   $0x80108c8f,(%esp)
80105cad:	e8 a2 a8 ff ff       	call   80100554 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105cb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cb5:	8b 40 04             	mov    0x4(%eax),%eax
80105cb8:	89 44 24 08          	mov    %eax,0x8(%esp)
80105cbc:	8d 45 de             	lea    -0x22(%ebp),%eax
80105cbf:	89 44 24 04          	mov    %eax,0x4(%esp)
80105cc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cc6:	89 04 24             	mov    %eax,(%esp)
80105cc9:	e8 62 c5 ff ff       	call   80102230 <dirlink>
80105cce:	85 c0                	test   %eax,%eax
80105cd0:	79 0c                	jns    80105cde <create+0x1ab>
    panic("create: dirlink");
80105cd2:	c7 04 24 9b 8c 10 80 	movl   $0x80108c9b,(%esp)
80105cd9:	e8 76 a8 ff ff       	call   80100554 <panic>

  iunlockput(dp);
80105cde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ce1:	89 04 24             	mov    %eax,(%esp)
80105ce4:	e8 d4 be ff ff       	call   80101bbd <iunlockput>

  return ip;
80105ce9:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105cec:	c9                   	leave  
80105ced:	c3                   	ret    

80105cee <sys_open>:

int
sys_open(void)
{
80105cee:	55                   	push   %ebp
80105cef:	89 e5                	mov    %esp,%ebp
80105cf1:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105cf4:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105cf7:	89 44 24 04          	mov    %eax,0x4(%esp)
80105cfb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105d02:	e8 f1 f6 ff ff       	call   801053f8 <argstr>
80105d07:	85 c0                	test   %eax,%eax
80105d09:	78 17                	js     80105d22 <sys_open+0x34>
80105d0b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105d0e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d12:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105d19:	e8 43 f6 ff ff       	call   80105361 <argint>
80105d1e:	85 c0                	test   %eax,%eax
80105d20:	79 0a                	jns    80105d2c <sys_open+0x3e>
    return -1;
80105d22:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d27:	e9 5b 01 00 00       	jmp    80105e87 <sys_open+0x199>

  begin_op();
80105d2c:	e8 86 d7 ff ff       	call   801034b7 <begin_op>

  if(omode & O_CREATE){
80105d31:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105d34:	25 00 02 00 00       	and    $0x200,%eax
80105d39:	85 c0                	test   %eax,%eax
80105d3b:	74 3b                	je     80105d78 <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
80105d3d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105d40:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105d47:	00 
80105d48:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105d4f:	00 
80105d50:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80105d57:	00 
80105d58:	89 04 24             	mov    %eax,(%esp)
80105d5b:	e8 d3 fd ff ff       	call   80105b33 <create>
80105d60:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105d63:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d67:	75 6a                	jne    80105dd3 <sys_open+0xe5>
      end_op();
80105d69:	e8 cb d7 ff ff       	call   80103539 <end_op>
      return -1;
80105d6e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d73:	e9 0f 01 00 00       	jmp    80105e87 <sys_open+0x199>
    }
  } else {
    if((ip = namei(path)) == 0){
80105d78:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105d7b:	89 04 24             	mov    %eax,(%esp)
80105d7e:	e8 60 c7 ff ff       	call   801024e3 <namei>
80105d83:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d86:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d8a:	75 0f                	jne    80105d9b <sys_open+0xad>
      end_op();
80105d8c:	e8 a8 d7 ff ff       	call   80103539 <end_op>
      return -1;
80105d91:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d96:	e9 ec 00 00 00       	jmp    80105e87 <sys_open+0x199>
    }
    ilock(ip);
80105d9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d9e:	89 04 24             	mov    %eax,(%esp)
80105da1:	e8 18 bc ff ff       	call   801019be <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80105da6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105da9:	8b 40 50             	mov    0x50(%eax),%eax
80105dac:	66 83 f8 01          	cmp    $0x1,%ax
80105db0:	75 21                	jne    80105dd3 <sys_open+0xe5>
80105db2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105db5:	85 c0                	test   %eax,%eax
80105db7:	74 1a                	je     80105dd3 <sys_open+0xe5>
      iunlockput(ip);
80105db9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dbc:	89 04 24             	mov    %eax,(%esp)
80105dbf:	e8 f9 bd ff ff       	call   80101bbd <iunlockput>
      end_op();
80105dc4:	e8 70 d7 ff ff       	call   80103539 <end_op>
      return -1;
80105dc9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dce:	e9 b4 00 00 00       	jmp    80105e87 <sys_open+0x199>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105dd3:	e8 24 b2 ff ff       	call   80100ffc <filealloc>
80105dd8:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ddb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ddf:	74 14                	je     80105df5 <sys_open+0x107>
80105de1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105de4:	89 04 24             	mov    %eax,(%esp)
80105de7:	e8 40 f7 ff ff       	call   8010552c <fdalloc>
80105dec:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105def:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105df3:	79 28                	jns    80105e1d <sys_open+0x12f>
    if(f)
80105df5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105df9:	74 0b                	je     80105e06 <sys_open+0x118>
      fileclose(f);
80105dfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dfe:	89 04 24             	mov    %eax,(%esp)
80105e01:	e8 9e b2 ff ff       	call   801010a4 <fileclose>
    iunlockput(ip);
80105e06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e09:	89 04 24             	mov    %eax,(%esp)
80105e0c:	e8 ac bd ff ff       	call   80101bbd <iunlockput>
    end_op();
80105e11:	e8 23 d7 ff ff       	call   80103539 <end_op>
    return -1;
80105e16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e1b:	eb 6a                	jmp    80105e87 <sys_open+0x199>
  }
  iunlock(ip);
80105e1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e20:	89 04 24             	mov    %eax,(%esp)
80105e23:	e8 a0 bc ff ff       	call   80101ac8 <iunlock>
  end_op();
80105e28:	e8 0c d7 ff ff       	call   80103539 <end_op>

  f->type = FD_INODE;
80105e2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e30:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105e36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e39:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105e3c:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105e3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e42:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105e49:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105e4c:	83 e0 01             	and    $0x1,%eax
80105e4f:	85 c0                	test   %eax,%eax
80105e51:	0f 94 c0             	sete   %al
80105e54:	88 c2                	mov    %al,%dl
80105e56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e59:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105e5c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105e5f:	83 e0 01             	and    $0x1,%eax
80105e62:	85 c0                	test   %eax,%eax
80105e64:	75 0a                	jne    80105e70 <sys_open+0x182>
80105e66:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105e69:	83 e0 02             	and    $0x2,%eax
80105e6c:	85 c0                	test   %eax,%eax
80105e6e:	74 07                	je     80105e77 <sys_open+0x189>
80105e70:	b8 01 00 00 00       	mov    $0x1,%eax
80105e75:	eb 05                	jmp    80105e7c <sys_open+0x18e>
80105e77:	b8 00 00 00 00       	mov    $0x0,%eax
80105e7c:	88 c2                	mov    %al,%dl
80105e7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e81:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105e84:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105e87:	c9                   	leave  
80105e88:	c3                   	ret    

80105e89 <sys_mkdir>:

int
sys_mkdir(void)
{
80105e89:	55                   	push   %ebp
80105e8a:	89 e5                	mov    %esp,%ebp
80105e8c:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105e8f:	e8 23 d6 ff ff       	call   801034b7 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105e94:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e97:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e9b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105ea2:	e8 51 f5 ff ff       	call   801053f8 <argstr>
80105ea7:	85 c0                	test   %eax,%eax
80105ea9:	78 2c                	js     80105ed7 <sys_mkdir+0x4e>
80105eab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eae:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105eb5:	00 
80105eb6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105ebd:	00 
80105ebe:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80105ec5:	00 
80105ec6:	89 04 24             	mov    %eax,(%esp)
80105ec9:	e8 65 fc ff ff       	call   80105b33 <create>
80105ece:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ed1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ed5:	75 0c                	jne    80105ee3 <sys_mkdir+0x5a>
    end_op();
80105ed7:	e8 5d d6 ff ff       	call   80103539 <end_op>
    return -1;
80105edc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ee1:	eb 15                	jmp    80105ef8 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
80105ee3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ee6:	89 04 24             	mov    %eax,(%esp)
80105ee9:	e8 cf bc ff ff       	call   80101bbd <iunlockput>
  end_op();
80105eee:	e8 46 d6 ff ff       	call   80103539 <end_op>
  return 0;
80105ef3:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ef8:	c9                   	leave  
80105ef9:	c3                   	ret    

80105efa <sys_mknod>:

int
sys_mknod(void)
{
80105efa:	55                   	push   %ebp
80105efb:	89 e5                	mov    %esp,%ebp
80105efd:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105f00:	e8 b2 d5 ff ff       	call   801034b7 <begin_op>
  if((argstr(0, &path)) < 0 ||
80105f05:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105f08:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f0c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105f13:	e8 e0 f4 ff ff       	call   801053f8 <argstr>
80105f18:	85 c0                	test   %eax,%eax
80105f1a:	78 5e                	js     80105f7a <sys_mknod+0x80>
     argint(1, &major) < 0 ||
80105f1c:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105f1f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f23:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105f2a:	e8 32 f4 ff ff       	call   80105361 <argint>
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
80105f2f:	85 c0                	test   %eax,%eax
80105f31:	78 47                	js     80105f7a <sys_mknod+0x80>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80105f33:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105f36:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f3a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105f41:	e8 1b f4 ff ff       	call   80105361 <argint>
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80105f46:	85 c0                	test   %eax,%eax
80105f48:	78 30                	js     80105f7a <sys_mknod+0x80>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80105f4a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f4d:	0f bf c8             	movswl %ax,%ecx
80105f50:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105f53:	0f bf d0             	movswl %ax,%edx
80105f56:	8b 45 f0             	mov    -0x10(%ebp),%eax
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80105f59:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80105f5d:	89 54 24 08          	mov    %edx,0x8(%esp)
80105f61:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80105f68:	00 
80105f69:	89 04 24             	mov    %eax,(%esp)
80105f6c:	e8 c2 fb ff ff       	call   80105b33 <create>
80105f71:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f74:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f78:	75 0c                	jne    80105f86 <sys_mknod+0x8c>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80105f7a:	e8 ba d5 ff ff       	call   80103539 <end_op>
    return -1;
80105f7f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f84:	eb 15                	jmp    80105f9b <sys_mknod+0xa1>
  }
  iunlockput(ip);
80105f86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f89:	89 04 24             	mov    %eax,(%esp)
80105f8c:	e8 2c bc ff ff       	call   80101bbd <iunlockput>
  end_op();
80105f91:	e8 a3 d5 ff ff       	call   80103539 <end_op>
  return 0;
80105f96:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f9b:	c9                   	leave  
80105f9c:	c3                   	ret    

80105f9d <sys_chdir>:

int
sys_chdir(void)
{
80105f9d:	55                   	push   %ebp
80105f9e:	89 e5                	mov    %esp,%ebp
80105fa0:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105fa3:	e8 07 e2 ff ff       	call   801041af <myproc>
80105fa8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80105fab:	e8 07 d5 ff ff       	call   801034b7 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105fb0:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105fb3:	89 44 24 04          	mov    %eax,0x4(%esp)
80105fb7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105fbe:	e8 35 f4 ff ff       	call   801053f8 <argstr>
80105fc3:	85 c0                	test   %eax,%eax
80105fc5:	78 14                	js     80105fdb <sys_chdir+0x3e>
80105fc7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105fca:	89 04 24             	mov    %eax,(%esp)
80105fcd:	e8 11 c5 ff ff       	call   801024e3 <namei>
80105fd2:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105fd5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105fd9:	75 0c                	jne    80105fe7 <sys_chdir+0x4a>
    end_op();
80105fdb:	e8 59 d5 ff ff       	call   80103539 <end_op>
    return -1;
80105fe0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fe5:	eb 5a                	jmp    80106041 <sys_chdir+0xa4>
  }
  ilock(ip);
80105fe7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fea:	89 04 24             	mov    %eax,(%esp)
80105fed:	e8 cc b9 ff ff       	call   801019be <ilock>
  if(ip->type != T_DIR){
80105ff2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ff5:	8b 40 50             	mov    0x50(%eax),%eax
80105ff8:	66 83 f8 01          	cmp    $0x1,%ax
80105ffc:	74 17                	je     80106015 <sys_chdir+0x78>
    iunlockput(ip);
80105ffe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106001:	89 04 24             	mov    %eax,(%esp)
80106004:	e8 b4 bb ff ff       	call   80101bbd <iunlockput>
    end_op();
80106009:	e8 2b d5 ff ff       	call   80103539 <end_op>
    return -1;
8010600e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106013:	eb 2c                	jmp    80106041 <sys_chdir+0xa4>
  }
  iunlock(ip);
80106015:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106018:	89 04 24             	mov    %eax,(%esp)
8010601b:	e8 a8 ba ff ff       	call   80101ac8 <iunlock>
  iput(curproc->cwd);
80106020:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106023:	8b 40 68             	mov    0x68(%eax),%eax
80106026:	89 04 24             	mov    %eax,(%esp)
80106029:	e8 de ba ff ff       	call   80101b0c <iput>
  end_op();
8010602e:	e8 06 d5 ff ff       	call   80103539 <end_op>
  curproc->cwd = ip;
80106033:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106036:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106039:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
8010603c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106041:	c9                   	leave  
80106042:	c3                   	ret    

80106043 <sys_exec>:

int
sys_exec(void)
{
80106043:	55                   	push   %ebp
80106044:	89 e5                	mov    %esp,%ebp
80106046:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
8010604c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010604f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106053:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010605a:	e8 99 f3 ff ff       	call   801053f8 <argstr>
8010605f:	85 c0                	test   %eax,%eax
80106061:	78 1a                	js     8010607d <sys_exec+0x3a>
80106063:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106069:	89 44 24 04          	mov    %eax,0x4(%esp)
8010606d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106074:	e8 e8 f2 ff ff       	call   80105361 <argint>
80106079:	85 c0                	test   %eax,%eax
8010607b:	79 0a                	jns    80106087 <sys_exec+0x44>
    return -1;
8010607d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106082:	e9 c7 00 00 00       	jmp    8010614e <sys_exec+0x10b>
  }
  memset(argv, 0, sizeof(argv));
80106087:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
8010608e:	00 
8010608f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106096:	00 
80106097:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010609d:	89 04 24             	mov    %eax,(%esp)
801060a0:	e8 89 ef ff ff       	call   8010502e <memset>
  for(i=0;; i++){
801060a5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801060ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060af:	83 f8 1f             	cmp    $0x1f,%eax
801060b2:	76 0a                	jbe    801060be <sys_exec+0x7b>
      return -1;
801060b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060b9:	e9 90 00 00 00       	jmp    8010614e <sys_exec+0x10b>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801060be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060c1:	c1 e0 02             	shl    $0x2,%eax
801060c4:	89 c2                	mov    %eax,%edx
801060c6:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801060cc:	01 c2                	add    %eax,%edx
801060ce:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801060d4:	89 44 24 04          	mov    %eax,0x4(%esp)
801060d8:	89 14 24             	mov    %edx,(%esp)
801060db:	e8 e0 f1 ff ff       	call   801052c0 <fetchint>
801060e0:	85 c0                	test   %eax,%eax
801060e2:	79 07                	jns    801060eb <sys_exec+0xa8>
      return -1;
801060e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060e9:	eb 63                	jmp    8010614e <sys_exec+0x10b>
    if(uarg == 0){
801060eb:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801060f1:	85 c0                	test   %eax,%eax
801060f3:	75 26                	jne    8010611b <sys_exec+0xd8>
      argv[i] = 0;
801060f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060f8:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801060ff:	00 00 00 00 
      break;
80106103:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106104:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106107:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
8010610d:	89 54 24 04          	mov    %edx,0x4(%esp)
80106111:	89 04 24             	mov    %eax,(%esp)
80106114:	e8 87 aa ff ff       	call   80100ba0 <exec>
80106119:	eb 33                	jmp    8010614e <sys_exec+0x10b>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
8010611b:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106121:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106124:	c1 e2 02             	shl    $0x2,%edx
80106127:	01 c2                	add    %eax,%edx
80106129:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010612f:	89 54 24 04          	mov    %edx,0x4(%esp)
80106133:	89 04 24             	mov    %eax,(%esp)
80106136:	e8 c4 f1 ff ff       	call   801052ff <fetchstr>
8010613b:	85 c0                	test   %eax,%eax
8010613d:	79 07                	jns    80106146 <sys_exec+0x103>
      return -1;
8010613f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106144:	eb 08                	jmp    8010614e <sys_exec+0x10b>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106146:	ff 45 f4             	incl   -0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106149:	e9 5e ff ff ff       	jmp    801060ac <sys_exec+0x69>
  return exec(path, argv);
}
8010614e:	c9                   	leave  
8010614f:	c3                   	ret    

80106150 <sys_pipe>:

int
sys_pipe(void)
{
80106150:	55                   	push   %ebp
80106151:	89 e5                	mov    %esp,%ebp
80106153:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106156:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
8010615d:	00 
8010615e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106161:	89 44 24 04          	mov    %eax,0x4(%esp)
80106165:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010616c:	e8 1d f2 ff ff       	call   8010538e <argptr>
80106171:	85 c0                	test   %eax,%eax
80106173:	79 0a                	jns    8010617f <sys_pipe+0x2f>
    return -1;
80106175:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010617a:	e9 9a 00 00 00       	jmp    80106219 <sys_pipe+0xc9>
  if(pipealloc(&rf, &wf) < 0)
8010617f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106182:	89 44 24 04          	mov    %eax,0x4(%esp)
80106186:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106189:	89 04 24             	mov    %eax,(%esp)
8010618c:	e8 73 db ff ff       	call   80103d04 <pipealloc>
80106191:	85 c0                	test   %eax,%eax
80106193:	79 07                	jns    8010619c <sys_pipe+0x4c>
    return -1;
80106195:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010619a:	eb 7d                	jmp    80106219 <sys_pipe+0xc9>
  fd0 = -1;
8010619c:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801061a3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801061a6:	89 04 24             	mov    %eax,(%esp)
801061a9:	e8 7e f3 ff ff       	call   8010552c <fdalloc>
801061ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
801061b1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061b5:	78 14                	js     801061cb <sys_pipe+0x7b>
801061b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061ba:	89 04 24             	mov    %eax,(%esp)
801061bd:	e8 6a f3 ff ff       	call   8010552c <fdalloc>
801061c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
801061c5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801061c9:	79 36                	jns    80106201 <sys_pipe+0xb1>
    if(fd0 >= 0)
801061cb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061cf:	78 13                	js     801061e4 <sys_pipe+0x94>
      myproc()->ofile[fd0] = 0;
801061d1:	e8 d9 df ff ff       	call   801041af <myproc>
801061d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801061d9:	83 c2 08             	add    $0x8,%edx
801061dc:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801061e3:	00 
    fileclose(rf);
801061e4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801061e7:	89 04 24             	mov    %eax,(%esp)
801061ea:	e8 b5 ae ff ff       	call   801010a4 <fileclose>
    fileclose(wf);
801061ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061f2:	89 04 24             	mov    %eax,(%esp)
801061f5:	e8 aa ae ff ff       	call   801010a4 <fileclose>
    return -1;
801061fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061ff:	eb 18                	jmp    80106219 <sys_pipe+0xc9>
  }
  fd[0] = fd0;
80106201:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106204:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106207:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106209:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010620c:	8d 50 04             	lea    0x4(%eax),%edx
8010620f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106212:	89 02                	mov    %eax,(%edx)
  return 0;
80106214:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106219:	c9                   	leave  
8010621a:	c3                   	ret    
	...

8010621c <sys_fork>:
#include "proc.h"
#include "container.h"

int
sys_fork(void)
{
8010621c:	55                   	push   %ebp
8010621d:	89 e5                	mov    %esp,%ebp
8010621f:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106222:	e8 91 e2 ff ff       	call   801044b8 <fork>
}
80106227:	c9                   	leave  
80106228:	c3                   	ret    

80106229 <sys_exit>:

int
sys_exit(void)
{
80106229:	55                   	push   %ebp
8010622a:	89 e5                	mov    %esp,%ebp
8010622c:	83 ec 08             	sub    $0x8,%esp
  exit();
8010622f:	e8 ea e3 ff ff       	call   8010461e <exit>
  return 0;  // not reached
80106234:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106239:	c9                   	leave  
8010623a:	c3                   	ret    

8010623b <sys_wait>:

int
sys_wait(void)
{
8010623b:	55                   	push   %ebp
8010623c:	89 e5                	mov    %esp,%ebp
8010623e:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106241:	e8 e1 e4 ff ff       	call   80104727 <wait>
}
80106246:	c9                   	leave  
80106247:	c3                   	ret    

80106248 <sys_kill>:

int
sys_kill(void)
{
80106248:	55                   	push   %ebp
80106249:	89 e5                	mov    %esp,%ebp
8010624b:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010624e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106251:	89 44 24 04          	mov    %eax,0x4(%esp)
80106255:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010625c:	e8 00 f1 ff ff       	call   80105361 <argint>
80106261:	85 c0                	test   %eax,%eax
80106263:	79 07                	jns    8010626c <sys_kill+0x24>
    return -1;
80106265:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010626a:	eb 0b                	jmp    80106277 <sys_kill+0x2f>
  return kill(pid);
8010626c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010626f:	89 04 24             	mov    %eax,(%esp)
80106272:	e8 85 e8 ff ff       	call   80104afc <kill>
}
80106277:	c9                   	leave  
80106278:	c3                   	ret    

80106279 <sys_getpid>:

int
sys_getpid(void)
{
80106279:	55                   	push   %ebp
8010627a:	89 e5                	mov    %esp,%ebp
8010627c:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
8010627f:	e8 2b df ff ff       	call   801041af <myproc>
80106284:	8b 40 10             	mov    0x10(%eax),%eax
}
80106287:	c9                   	leave  
80106288:	c3                   	ret    

80106289 <sys_sbrk>:

int
sys_sbrk(void)
{
80106289:	55                   	push   %ebp
8010628a:	89 e5                	mov    %esp,%ebp
8010628c:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010628f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106292:	89 44 24 04          	mov    %eax,0x4(%esp)
80106296:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010629d:	e8 bf f0 ff ff       	call   80105361 <argint>
801062a2:	85 c0                	test   %eax,%eax
801062a4:	79 07                	jns    801062ad <sys_sbrk+0x24>
    return -1;
801062a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062ab:	eb 23                	jmp    801062d0 <sys_sbrk+0x47>
  addr = myproc()->sz;
801062ad:	e8 fd de ff ff       	call   801041af <myproc>
801062b2:	8b 00                	mov    (%eax),%eax
801062b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801062b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062ba:	89 04 24             	mov    %eax,(%esp)
801062bd:	e8 58 e1 ff ff       	call   8010441a <growproc>
801062c2:	85 c0                	test   %eax,%eax
801062c4:	79 07                	jns    801062cd <sys_sbrk+0x44>
    return -1;
801062c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062cb:	eb 03                	jmp    801062d0 <sys_sbrk+0x47>
  return addr;
801062cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801062d0:	c9                   	leave  
801062d1:	c3                   	ret    

801062d2 <sys_sleep>:

int
sys_sleep(void)
{
801062d2:	55                   	push   %ebp
801062d3:	89 e5                	mov    %esp,%ebp
801062d5:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
801062d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062db:	89 44 24 04          	mov    %eax,0x4(%esp)
801062df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801062e6:	e8 76 f0 ff ff       	call   80105361 <argint>
801062eb:	85 c0                	test   %eax,%eax
801062ed:	79 07                	jns    801062f6 <sys_sleep+0x24>
    return -1;
801062ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062f4:	eb 6b                	jmp    80106361 <sys_sleep+0x8f>
  acquire(&tickslock);
801062f6:	c7 04 24 80 60 11 80 	movl   $0x80116080,(%esp)
801062fd:	e8 c9 ea ff ff       	call   80104dcb <acquire>
  ticks0 = ticks;
80106302:	a1 c0 68 11 80       	mov    0x801168c0,%eax
80106307:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
8010630a:	eb 33                	jmp    8010633f <sys_sleep+0x6d>
    if(myproc()->killed){
8010630c:	e8 9e de ff ff       	call   801041af <myproc>
80106311:	8b 40 24             	mov    0x24(%eax),%eax
80106314:	85 c0                	test   %eax,%eax
80106316:	74 13                	je     8010632b <sys_sleep+0x59>
      release(&tickslock);
80106318:	c7 04 24 80 60 11 80 	movl   $0x80116080,(%esp)
8010631f:	e8 11 eb ff ff       	call   80104e35 <release>
      return -1;
80106324:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106329:	eb 36                	jmp    80106361 <sys_sleep+0x8f>
    }
    sleep(&ticks, &tickslock);
8010632b:	c7 44 24 04 80 60 11 	movl   $0x80116080,0x4(%esp)
80106332:	80 
80106333:	c7 04 24 c0 68 11 80 	movl   $0x801168c0,(%esp)
8010633a:	e8 be e6 ff ff       	call   801049fd <sleep>

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
8010633f:	a1 c0 68 11 80       	mov    0x801168c0,%eax
80106344:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106347:	89 c2                	mov    %eax,%edx
80106349:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010634c:	39 c2                	cmp    %eax,%edx
8010634e:	72 bc                	jb     8010630c <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106350:	c7 04 24 80 60 11 80 	movl   $0x80116080,(%esp)
80106357:	e8 d9 ea ff ff       	call   80104e35 <release>
  return 0;
8010635c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106361:	c9                   	leave  
80106362:	c3                   	ret    

80106363 <sys_get_name>:

void sys_get_name(void){
80106363:	55                   	push   %ebp
80106364:	89 e5                	mov    %esp,%ebp
80106366:	83 ec 28             	sub    $0x28,%esp

  char* name;
  fetchstr(0, &name);
80106369:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010636c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106370:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106377:	e8 83 ef ff ff       	call   801052ff <fetchstr>

  int vc_num;
  fetchint(1, &vc_num);
8010637c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010637f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106383:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010638a:	e8 31 ef ff ff       	call   801052c0 <fetchint>

  get_name(name, vc_num);
8010638f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106392:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106395:	89 54 24 04          	mov    %edx,0x4(%esp)
80106399:	89 04 24             	mov    %eax,(%esp)
8010639c:	e8 21 21 00 00       	call   801084c2 <get_name>
  return;
801063a1:	90                   	nop
}
801063a2:	c9                   	leave  
801063a3:	c3                   	ret    

801063a4 <sys_get_max_proc>:

int sys_get_max_proc(void){
801063a4:	55                   	push   %ebp
801063a5:	89 e5                	mov    %esp,%ebp
801063a7:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  fetchint(0, &vc_num);
801063aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
801063ad:	89 44 24 04          	mov    %eax,0x4(%esp)
801063b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801063b8:	e8 03 ef ff ff       	call   801052c0 <fetchint>


  return get_max_proc(vc_num);  
801063bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063c0:	89 04 24             	mov    %eax,(%esp)
801063c3:	e8 48 21 00 00       	call   80108510 <get_max_proc>
}
801063c8:	c9                   	leave  
801063c9:	c3                   	ret    

801063ca <sys_get_max_mem>:

int sys_get_max_mem(void){
801063ca:	55                   	push   %ebp
801063cb:	89 e5                	mov    %esp,%ebp
801063cd:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  fetchint(0, &vc_num);
801063d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
801063d3:	89 44 24 04          	mov    %eax,0x4(%esp)
801063d7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801063de:	e8 dd ee ff ff       	call   801052c0 <fetchint>


  return get_max_mem(vc_num);
801063e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063e6:	89 04 24             	mov    %eax,(%esp)
801063e9:	e8 61 21 00 00       	call   8010854f <get_max_mem>
}
801063ee:	c9                   	leave  
801063ef:	c3                   	ret    

801063f0 <sys_get_max_disk>:

int sys_get_max_disk(void){
801063f0:	55                   	push   %ebp
801063f1:	89 e5                	mov    %esp,%ebp
801063f3:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  fetchint(0, &vc_num);
801063f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
801063f9:	89 44 24 04          	mov    %eax,0x4(%esp)
801063fd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106404:	e8 b7 ee ff ff       	call   801052c0 <fetchint>


  return get_max_disk(vc_num);
80106409:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010640c:	89 04 24             	mov    %eax,(%esp)
8010640f:	e8 7a 21 00 00       	call   8010858e <get_max_disk>

}
80106414:	c9                   	leave  
80106415:	c3                   	ret    

80106416 <sys_get_curr_proc>:

int sys_get_curr_proc(void){
80106416:	55                   	push   %ebp
80106417:	89 e5                	mov    %esp,%ebp
80106419:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  fetchint(0, &vc_num);
8010641c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010641f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106423:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010642a:	e8 91 ee ff ff       	call   801052c0 <fetchint>


  return get_curr_proc(vc_num);
8010642f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106432:	89 04 24             	mov    %eax,(%esp)
80106435:	e8 93 21 00 00       	call   801085cd <get_curr_proc>
}
8010643a:	c9                   	leave  
8010643b:	c3                   	ret    

8010643c <sys_get_curr_mem>:

int sys_get_curr_mem(void){
8010643c:	55                   	push   %ebp
8010643d:	89 e5                	mov    %esp,%ebp
8010643f:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  fetchint(0, &vc_num);
80106442:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106445:	89 44 24 04          	mov    %eax,0x4(%esp)
80106449:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106450:	e8 6b ee ff ff       	call   801052c0 <fetchint>


  return get_curr_mem(vc_num);
80106455:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106458:	89 04 24             	mov    %eax,(%esp)
8010645b:	e8 ac 21 00 00       	call   8010860c <get_curr_mem>
}
80106460:	c9                   	leave  
80106461:	c3                   	ret    

80106462 <sys_get_curr_disk>:

int sys_get_curr_disk(void){
80106462:	55                   	push   %ebp
80106463:	89 e5                	mov    %esp,%ebp
80106465:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  fetchint(0, &vc_num);
80106468:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010646b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010646f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106476:	e8 45 ee ff ff       	call   801052c0 <fetchint>


  return get_curr_disk(vc_num);
8010647b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010647e:	89 04 24             	mov    %eax,(%esp)
80106481:	e8 c5 21 00 00       	call   8010864b <get_curr_disk>
}
80106486:	c9                   	leave  
80106487:	c3                   	ret    

80106488 <sys_set_name>:

void sys_set_name(void){
80106488:	55                   	push   %ebp
80106489:	89 e5                	mov    %esp,%ebp
8010648b:	83 ec 28             	sub    $0x28,%esp
  char* name;
  fetchstr(0, &name);
8010648e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106491:	89 44 24 04          	mov    %eax,0x4(%esp)
80106495:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010649c:	e8 5e ee ff ff       	call   801052ff <fetchstr>

  int vc_num;
  fetchint(1, &vc_num);
801064a1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801064a8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801064af:	e8 0c ee ff ff       	call   801052c0 <fetchint>

  set_name(name, vc_num);
801064b4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801064b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064ba:	89 54 24 04          	mov    %edx,0x4(%esp)
801064be:	89 04 24             	mov    %eax,(%esp)
801064c1:	e8 c4 21 00 00       	call   8010868a <set_name>
}
801064c6:	c9                   	leave  
801064c7:	c3                   	ret    

801064c8 <sys_set_max_mem>:

void sys_set_max_mem(void){
801064c8:	55                   	push   %ebp
801064c9:	89 e5                	mov    %esp,%ebp
801064cb:	83 ec 28             	sub    $0x28,%esp
  int mem;
  fetchint(0, &mem);
801064ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
801064d1:	89 44 24 04          	mov    %eax,0x4(%esp)
801064d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801064dc:	e8 df ed ff ff       	call   801052c0 <fetchint>

  int vc_num;
  fetchint(1, &vc_num);
801064e1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064e4:	89 44 24 04          	mov    %eax,0x4(%esp)
801064e8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801064ef:	e8 cc ed ff ff       	call   801052c0 <fetchint>

  set_max_mem(mem, vc_num);
801064f4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801064f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064fa:	89 54 24 04          	mov    %edx,0x4(%esp)
801064fe:	89 04 24             	mov    %eax,(%esp)
80106501:	e8 b7 21 00 00       	call   801086bd <set_max_mem>
}
80106506:	c9                   	leave  
80106507:	c3                   	ret    

80106508 <sys_set_max_disk>:

void sys_set_max_disk(void){
80106508:	55                   	push   %ebp
80106509:	89 e5                	mov    %esp,%ebp
8010650b:	83 ec 28             	sub    $0x28,%esp
  int disk;
  fetchint(0, &disk);
8010650e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106511:	89 44 24 04          	mov    %eax,0x4(%esp)
80106515:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010651c:	e8 9f ed ff ff       	call   801052c0 <fetchint>

  int vc_num;
  fetchint(1, &vc_num);
80106521:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106524:	89 44 24 04          	mov    %eax,0x4(%esp)
80106528:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010652f:	e8 8c ed ff ff       	call   801052c0 <fetchint>

  set_max_disk(disk, vc_num);
80106534:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106537:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010653a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010653e:	89 04 24             	mov    %eax,(%esp)
80106541:	e8 9b 21 00 00       	call   801086e1 <set_max_disk>
}
80106546:	c9                   	leave  
80106547:	c3                   	ret    

80106548 <sys_set_max_proc>:

void sys_set_max_proc(void){
80106548:	55                   	push   %ebp
80106549:	89 e5                	mov    %esp,%ebp
8010654b:	83 ec 28             	sub    $0x28,%esp
  int proc;
  fetchint(0, &proc);
8010654e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106551:	89 44 24 04          	mov    %eax,0x4(%esp)
80106555:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010655c:	e8 5f ed ff ff       	call   801052c0 <fetchint>

  int vc_num;
  fetchint(1, &vc_num);
80106561:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106564:	89 44 24 04          	mov    %eax,0x4(%esp)
80106568:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010656f:	e8 4c ed ff ff       	call   801052c0 <fetchint>

  set_max_proc(proc, vc_num);
80106574:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106577:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010657a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010657e:	89 04 24             	mov    %eax,(%esp)
80106581:	e8 80 21 00 00       	call   80108706 <set_max_proc>
}
80106586:	c9                   	leave  
80106587:	c3                   	ret    

80106588 <sys_set_curr_mem>:

void sys_set_curr_mem(void){
80106588:	55                   	push   %ebp
80106589:	89 e5                	mov    %esp,%ebp
8010658b:	83 ec 28             	sub    $0x28,%esp
  int mem;
  fetchint(0, &mem);
8010658e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106591:	89 44 24 04          	mov    %eax,0x4(%esp)
80106595:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010659c:	e8 1f ed ff ff       	call   801052c0 <fetchint>

  int vc_num;
  fetchint(1, &vc_num);
801065a1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801065a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801065a8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801065af:	e8 0c ed ff ff       	call   801052c0 <fetchint>

  set_curr_mem(mem, vc_num);
801065b4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801065b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065ba:	89 54 24 04          	mov    %edx,0x4(%esp)
801065be:	89 04 24             	mov    %eax,(%esp)
801065c1:	e8 65 21 00 00       	call   8010872b <set_curr_mem>
}
801065c6:	c9                   	leave  
801065c7:	c3                   	ret    

801065c8 <sys_set_curr_disk>:

void sys_set_curr_disk(void){
801065c8:	55                   	push   %ebp
801065c9:	89 e5                	mov    %esp,%ebp
801065cb:	83 ec 28             	sub    $0x28,%esp
  int disk;
  fetchint(0, &disk);
801065ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
801065d1:	89 44 24 04          	mov    %eax,0x4(%esp)
801065d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801065dc:	e8 df ec ff ff       	call   801052c0 <fetchint>

  int vc_num;
  fetchint(1, &vc_num);
801065e1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801065e4:	89 44 24 04          	mov    %eax,0x4(%esp)
801065e8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801065ef:	e8 cc ec ff ff       	call   801052c0 <fetchint>

  set_curr_disk(disk, vc_num);
801065f4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801065f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065fa:	89 54 24 04          	mov    %edx,0x4(%esp)
801065fe:	89 04 24             	mov    %eax,(%esp)
80106601:	e8 4a 21 00 00       	call   80108750 <set_curr_disk>
}
80106606:	c9                   	leave  
80106607:	c3                   	ret    

80106608 <sys_set_curr_proc>:

void sys_set_curr_proc(void){
80106608:	55                   	push   %ebp
80106609:	89 e5                	mov    %esp,%ebp
8010660b:	83 ec 28             	sub    $0x28,%esp
  int proc;
  fetchint(0, &proc);
8010660e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106611:	89 44 24 04          	mov    %eax,0x4(%esp)
80106615:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010661c:	e8 9f ec ff ff       	call   801052c0 <fetchint>

  int vc_num;
  fetchint(1, &vc_num);
80106621:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106624:	89 44 24 04          	mov    %eax,0x4(%esp)
80106628:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010662f:	e8 8c ec ff ff       	call   801052c0 <fetchint>

  set_curr_proc(proc, vc_num);
80106634:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106637:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010663a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010663e:	89 04 24             	mov    %eax,(%esp)
80106641:	e8 2f 21 00 00       	call   80108775 <set_curr_proc>
}
80106646:	c9                   	leave  
80106647:	c3                   	ret    

80106648 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106648:	55                   	push   %ebp
80106649:	89 e5                	mov    %esp,%ebp
8010664b:	83 ec 28             	sub    $0x28,%esp
  uint xticks;

  acquire(&tickslock);
8010664e:	c7 04 24 80 60 11 80 	movl   $0x80116080,(%esp)
80106655:	e8 71 e7 ff ff       	call   80104dcb <acquire>
  xticks = ticks;
8010665a:	a1 c0 68 11 80       	mov    0x801168c0,%eax
8010665f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106662:	c7 04 24 80 60 11 80 	movl   $0x80116080,(%esp)
80106669:	e8 c7 e7 ff ff       	call   80104e35 <release>
  return xticks;
8010666e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106671:	c9                   	leave  
80106672:	c3                   	ret    

80106673 <sys_getticks>:

int
sys_getticks(void)
{
80106673:	55                   	push   %ebp
80106674:	89 e5                	mov    %esp,%ebp
80106676:	83 ec 08             	sub    $0x8,%esp
  return myproc()->ticks;
80106679:	e8 31 db ff ff       	call   801041af <myproc>
8010667e:	8b 40 7c             	mov    0x7c(%eax),%eax
}
80106681:	c9                   	leave  
80106682:	c3                   	ret    
	...

80106684 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106684:	1e                   	push   %ds
  pushl %es
80106685:	06                   	push   %es
  pushl %fs
80106686:	0f a0                	push   %fs
  pushl %gs
80106688:	0f a8                	push   %gs
  pushal
8010668a:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
8010668b:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010668f:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106691:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106693:	54                   	push   %esp
  call trap
80106694:	e8 c0 01 00 00       	call   80106859 <trap>
  addl $4, %esp
80106699:	83 c4 04             	add    $0x4,%esp

8010669c <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
8010669c:	61                   	popa   
  popl %gs
8010669d:	0f a9                	pop    %gs
  popl %fs
8010669f:	0f a1                	pop    %fs
  popl %es
801066a1:	07                   	pop    %es
  popl %ds
801066a2:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801066a3:	83 c4 08             	add    $0x8,%esp
  iret
801066a6:	cf                   	iret   
	...

801066a8 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
801066a8:	55                   	push   %ebp
801066a9:	89 e5                	mov    %esp,%ebp
801066ab:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801066ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801066b1:	48                   	dec    %eax
801066b2:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801066b6:	8b 45 08             	mov    0x8(%ebp),%eax
801066b9:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801066bd:	8b 45 08             	mov    0x8(%ebp),%eax
801066c0:	c1 e8 10             	shr    $0x10,%eax
801066c3:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
801066c7:	8d 45 fa             	lea    -0x6(%ebp),%eax
801066ca:	0f 01 18             	lidtl  (%eax)
}
801066cd:	c9                   	leave  
801066ce:	c3                   	ret    

801066cf <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
801066cf:	55                   	push   %ebp
801066d0:	89 e5                	mov    %esp,%ebp
801066d2:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801066d5:	0f 20 d0             	mov    %cr2,%eax
801066d8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801066db:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801066de:	c9                   	leave  
801066df:	c3                   	ret    

801066e0 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801066e0:	55                   	push   %ebp
801066e1:	89 e5                	mov    %esp,%ebp
801066e3:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
801066e6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801066ed:	e9 b8 00 00 00       	jmp    801067aa <tvinit+0xca>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801066f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066f5:	8b 04 85 b4 b0 10 80 	mov    -0x7fef4f4c(,%eax,4),%eax
801066fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801066ff:	66 89 04 d5 c0 60 11 	mov    %ax,-0x7fee9f40(,%edx,8)
80106706:	80 
80106707:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010670a:	66 c7 04 c5 c2 60 11 	movw   $0x8,-0x7fee9f3e(,%eax,8)
80106711:	80 08 00 
80106714:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106717:	8a 14 c5 c4 60 11 80 	mov    -0x7fee9f3c(,%eax,8),%dl
8010671e:	83 e2 e0             	and    $0xffffffe0,%edx
80106721:	88 14 c5 c4 60 11 80 	mov    %dl,-0x7fee9f3c(,%eax,8)
80106728:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010672b:	8a 14 c5 c4 60 11 80 	mov    -0x7fee9f3c(,%eax,8),%dl
80106732:	83 e2 1f             	and    $0x1f,%edx
80106735:	88 14 c5 c4 60 11 80 	mov    %dl,-0x7fee9f3c(,%eax,8)
8010673c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010673f:	8a 14 c5 c5 60 11 80 	mov    -0x7fee9f3b(,%eax,8),%dl
80106746:	83 e2 f0             	and    $0xfffffff0,%edx
80106749:	83 ca 0e             	or     $0xe,%edx
8010674c:	88 14 c5 c5 60 11 80 	mov    %dl,-0x7fee9f3b(,%eax,8)
80106753:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106756:	8a 14 c5 c5 60 11 80 	mov    -0x7fee9f3b(,%eax,8),%dl
8010675d:	83 e2 ef             	and    $0xffffffef,%edx
80106760:	88 14 c5 c5 60 11 80 	mov    %dl,-0x7fee9f3b(,%eax,8)
80106767:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010676a:	8a 14 c5 c5 60 11 80 	mov    -0x7fee9f3b(,%eax,8),%dl
80106771:	83 e2 9f             	and    $0xffffff9f,%edx
80106774:	88 14 c5 c5 60 11 80 	mov    %dl,-0x7fee9f3b(,%eax,8)
8010677b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010677e:	8a 14 c5 c5 60 11 80 	mov    -0x7fee9f3b(,%eax,8),%dl
80106785:	83 ca 80             	or     $0xffffff80,%edx
80106788:	88 14 c5 c5 60 11 80 	mov    %dl,-0x7fee9f3b(,%eax,8)
8010678f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106792:	8b 04 85 b4 b0 10 80 	mov    -0x7fef4f4c(,%eax,4),%eax
80106799:	c1 e8 10             	shr    $0x10,%eax
8010679c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010679f:	66 89 04 d5 c6 60 11 	mov    %ax,-0x7fee9f3a(,%edx,8)
801067a6:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
801067a7:	ff 45 f4             	incl   -0xc(%ebp)
801067aa:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801067b1:	0f 8e 3b ff ff ff    	jle    801066f2 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801067b7:	a1 b4 b1 10 80       	mov    0x8010b1b4,%eax
801067bc:	66 a3 c0 62 11 80    	mov    %ax,0x801162c0
801067c2:	66 c7 05 c2 62 11 80 	movw   $0x8,0x801162c2
801067c9:	08 00 
801067cb:	a0 c4 62 11 80       	mov    0x801162c4,%al
801067d0:	83 e0 e0             	and    $0xffffffe0,%eax
801067d3:	a2 c4 62 11 80       	mov    %al,0x801162c4
801067d8:	a0 c4 62 11 80       	mov    0x801162c4,%al
801067dd:	83 e0 1f             	and    $0x1f,%eax
801067e0:	a2 c4 62 11 80       	mov    %al,0x801162c4
801067e5:	a0 c5 62 11 80       	mov    0x801162c5,%al
801067ea:	83 c8 0f             	or     $0xf,%eax
801067ed:	a2 c5 62 11 80       	mov    %al,0x801162c5
801067f2:	a0 c5 62 11 80       	mov    0x801162c5,%al
801067f7:	83 e0 ef             	and    $0xffffffef,%eax
801067fa:	a2 c5 62 11 80       	mov    %al,0x801162c5
801067ff:	a0 c5 62 11 80       	mov    0x801162c5,%al
80106804:	83 c8 60             	or     $0x60,%eax
80106807:	a2 c5 62 11 80       	mov    %al,0x801162c5
8010680c:	a0 c5 62 11 80       	mov    0x801162c5,%al
80106811:	83 c8 80             	or     $0xffffff80,%eax
80106814:	a2 c5 62 11 80       	mov    %al,0x801162c5
80106819:	a1 b4 b1 10 80       	mov    0x8010b1b4,%eax
8010681e:	c1 e8 10             	shr    $0x10,%eax
80106821:	66 a3 c6 62 11 80    	mov    %ax,0x801162c6

  initlock(&tickslock, "time");
80106827:	c7 44 24 04 ac 8c 10 	movl   $0x80108cac,0x4(%esp)
8010682e:	80 
8010682f:	c7 04 24 80 60 11 80 	movl   $0x80116080,(%esp)
80106836:	e8 6f e5 ff ff       	call   80104daa <initlock>
}
8010683b:	c9                   	leave  
8010683c:	c3                   	ret    

8010683d <idtinit>:

void
idtinit(void)
{
8010683d:	55                   	push   %ebp
8010683e:	89 e5                	mov    %esp,%ebp
80106840:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
80106843:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
8010684a:	00 
8010684b:	c7 04 24 c0 60 11 80 	movl   $0x801160c0,(%esp)
80106852:	e8 51 fe ff ff       	call   801066a8 <lidt>
}
80106857:	c9                   	leave  
80106858:	c3                   	ret    

80106859 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106859:	55                   	push   %ebp
8010685a:	89 e5                	mov    %esp,%ebp
8010685c:	57                   	push   %edi
8010685d:	56                   	push   %esi
8010685e:	53                   	push   %ebx
8010685f:	83 ec 4c             	sub    $0x4c,%esp
  struct proc *p;
  if(tf->trapno == T_SYSCALL){
80106862:	8b 45 08             	mov    0x8(%ebp),%eax
80106865:	8b 40 30             	mov    0x30(%eax),%eax
80106868:	83 f8 40             	cmp    $0x40,%eax
8010686b:	75 3c                	jne    801068a9 <trap+0x50>
    if(myproc()->killed)
8010686d:	e8 3d d9 ff ff       	call   801041af <myproc>
80106872:	8b 40 24             	mov    0x24(%eax),%eax
80106875:	85 c0                	test   %eax,%eax
80106877:	74 05                	je     8010687e <trap+0x25>
      exit();
80106879:	e8 a0 dd ff ff       	call   8010461e <exit>
    myproc()->tf = tf;
8010687e:	e8 2c d9 ff ff       	call   801041af <myproc>
80106883:	8b 55 08             	mov    0x8(%ebp),%edx
80106886:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106889:	e8 a1 eb ff ff       	call   8010542f <syscall>
    if(myproc()->killed)
8010688e:	e8 1c d9 ff ff       	call   801041af <myproc>
80106893:	8b 40 24             	mov    0x24(%eax),%eax
80106896:	85 c0                	test   %eax,%eax
80106898:	74 0a                	je     801068a4 <trap+0x4b>
      exit();
8010689a:	e8 7f dd ff ff       	call   8010461e <exit>
    return;
8010689f:	e9 30 02 00 00       	jmp    80106ad4 <trap+0x27b>
801068a4:	e9 2b 02 00 00       	jmp    80106ad4 <trap+0x27b>
  }

  switch(tf->trapno){
801068a9:	8b 45 08             	mov    0x8(%ebp),%eax
801068ac:	8b 40 30             	mov    0x30(%eax),%eax
801068af:	83 e8 20             	sub    $0x20,%eax
801068b2:	83 f8 1f             	cmp    $0x1f,%eax
801068b5:	0f 87 cb 00 00 00    	ja     80106986 <trap+0x12d>
801068bb:	8b 04 85 54 8d 10 80 	mov    -0x7fef72ac(,%eax,4),%eax
801068c2:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
801068c4:	e8 1d d8 ff ff       	call   801040e6 <cpuid>
801068c9:	85 c0                	test   %eax,%eax
801068cb:	75 2f                	jne    801068fc <trap+0xa3>
      acquire(&tickslock);
801068cd:	c7 04 24 80 60 11 80 	movl   $0x80116080,(%esp)
801068d4:	e8 f2 e4 ff ff       	call   80104dcb <acquire>
      ticks++;
801068d9:	a1 c0 68 11 80       	mov    0x801168c0,%eax
801068de:	40                   	inc    %eax
801068df:	a3 c0 68 11 80       	mov    %eax,0x801168c0
      wakeup(&ticks);
801068e4:	c7 04 24 c0 68 11 80 	movl   $0x801168c0,(%esp)
801068eb:	e8 e1 e1 ff ff       	call   80104ad1 <wakeup>
      release(&tickslock);
801068f0:	c7 04 24 80 60 11 80 	movl   $0x80116080,(%esp)
801068f7:	e8 39 e5 ff ff       	call   80104e35 <release>
    }
    p = myproc();
801068fc:	e8 ae d8 ff ff       	call   801041af <myproc>
80106901:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (p != 0) {
80106904:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80106908:	74 0f                	je     80106919 <trap+0xc0>
      p->ticks++;
8010690a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010690d:	8b 40 7c             	mov    0x7c(%eax),%eax
80106910:	8d 50 01             	lea    0x1(%eax),%edx
80106913:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106916:	89 50 7c             	mov    %edx,0x7c(%eax)
    }
    lapiceoi();
80106919:	e8 71 c6 ff ff       	call   80102f8f <lapiceoi>
    break;
8010691e:	e9 35 01 00 00       	jmp    80106a58 <trap+0x1ff>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106923:	e8 e6 be ff ff       	call   8010280e <ideintr>
    lapiceoi();
80106928:	e8 62 c6 ff ff       	call   80102f8f <lapiceoi>
    break;
8010692d:	e9 26 01 00 00       	jmp    80106a58 <trap+0x1ff>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106932:	e8 6f c4 ff ff       	call   80102da6 <kbdintr>
    lapiceoi();
80106937:	e8 53 c6 ff ff       	call   80102f8f <lapiceoi>
    break;
8010693c:	e9 17 01 00 00       	jmp    80106a58 <trap+0x1ff>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106941:	e8 6f 03 00 00       	call   80106cb5 <uartintr>
    lapiceoi();
80106946:	e8 44 c6 ff ff       	call   80102f8f <lapiceoi>
    break;
8010694b:	e9 08 01 00 00       	jmp    80106a58 <trap+0x1ff>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106950:	8b 45 08             	mov    0x8(%ebp),%eax
80106953:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106956:	8b 45 08             	mov    0x8(%ebp),%eax
80106959:	8b 40 3c             	mov    0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010695c:	0f b7 d8             	movzwl %ax,%ebx
8010695f:	e8 82 d7 ff ff       	call   801040e6 <cpuid>
80106964:	89 74 24 0c          	mov    %esi,0xc(%esp)
80106968:	89 5c 24 08          	mov    %ebx,0x8(%esp)
8010696c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106970:	c7 04 24 b4 8c 10 80 	movl   $0x80108cb4,(%esp)
80106977:	e8 45 9a ff ff       	call   801003c1 <cprintf>
            cpuid(), tf->cs, tf->eip);
    lapiceoi();
8010697c:	e8 0e c6 ff ff       	call   80102f8f <lapiceoi>
    break;
80106981:	e9 d2 00 00 00       	jmp    80106a58 <trap+0x1ff>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106986:	e8 24 d8 ff ff       	call   801041af <myproc>
8010698b:	85 c0                	test   %eax,%eax
8010698d:	74 10                	je     8010699f <trap+0x146>
8010698f:	8b 45 08             	mov    0x8(%ebp),%eax
80106992:	8b 40 3c             	mov    0x3c(%eax),%eax
80106995:	0f b7 c0             	movzwl %ax,%eax
80106998:	83 e0 03             	and    $0x3,%eax
8010699b:	85 c0                	test   %eax,%eax
8010699d:	75 40                	jne    801069df <trap+0x186>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010699f:	e8 2b fd ff ff       	call   801066cf <rcr2>
801069a4:	89 c3                	mov    %eax,%ebx
801069a6:	8b 45 08             	mov    0x8(%ebp),%eax
801069a9:	8b 70 38             	mov    0x38(%eax),%esi
801069ac:	e8 35 d7 ff ff       	call   801040e6 <cpuid>
801069b1:	8b 55 08             	mov    0x8(%ebp),%edx
801069b4:	8b 52 30             	mov    0x30(%edx),%edx
801069b7:	89 5c 24 10          	mov    %ebx,0x10(%esp)
801069bb:	89 74 24 0c          	mov    %esi,0xc(%esp)
801069bf:	89 44 24 08          	mov    %eax,0x8(%esp)
801069c3:	89 54 24 04          	mov    %edx,0x4(%esp)
801069c7:	c7 04 24 d8 8c 10 80 	movl   $0x80108cd8,(%esp)
801069ce:	e8 ee 99 ff ff       	call   801003c1 <cprintf>
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
801069d3:	c7 04 24 0a 8d 10 80 	movl   $0x80108d0a,(%esp)
801069da:	e8 75 9b ff ff       	call   80100554 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801069df:	e8 eb fc ff ff       	call   801066cf <rcr2>
801069e4:	89 c6                	mov    %eax,%esi
801069e6:	8b 45 08             	mov    0x8(%ebp),%eax
801069e9:	8b 40 38             	mov    0x38(%eax),%eax
801069ec:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801069ef:	e8 f2 d6 ff ff       	call   801040e6 <cpuid>
801069f4:	89 c3                	mov    %eax,%ebx
801069f6:	8b 45 08             	mov    0x8(%ebp),%eax
801069f9:	8b 78 34             	mov    0x34(%eax),%edi
801069fc:	89 7d d0             	mov    %edi,-0x30(%ebp)
801069ff:	8b 45 08             	mov    0x8(%ebp),%eax
80106a02:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106a05:	e8 a5 d7 ff ff       	call   801041af <myproc>
80106a0a:	8d 50 6c             	lea    0x6c(%eax),%edx
80106a0d:	89 55 cc             	mov    %edx,-0x34(%ebp)
80106a10:	e8 9a d7 ff ff       	call   801041af <myproc>
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106a15:	8b 40 10             	mov    0x10(%eax),%eax
80106a18:	89 74 24 1c          	mov    %esi,0x1c(%esp)
80106a1c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
80106a1f:	89 4c 24 18          	mov    %ecx,0x18(%esp)
80106a23:	89 5c 24 14          	mov    %ebx,0x14(%esp)
80106a27:	8b 4d d0             	mov    -0x30(%ebp),%ecx
80106a2a:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80106a2e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
80106a32:	8b 55 cc             	mov    -0x34(%ebp),%edx
80106a35:	89 54 24 08          	mov    %edx,0x8(%esp)
80106a39:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a3d:	c7 04 24 10 8d 10 80 	movl   $0x80108d10,(%esp)
80106a44:	e8 78 99 ff ff       	call   801003c1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106a49:	e8 61 d7 ff ff       	call   801041af <myproc>
80106a4e:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106a55:	eb 01                	jmp    80106a58 <trap+0x1ff>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106a57:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106a58:	e8 52 d7 ff ff       	call   801041af <myproc>
80106a5d:	85 c0                	test   %eax,%eax
80106a5f:	74 22                	je     80106a83 <trap+0x22a>
80106a61:	e8 49 d7 ff ff       	call   801041af <myproc>
80106a66:	8b 40 24             	mov    0x24(%eax),%eax
80106a69:	85 c0                	test   %eax,%eax
80106a6b:	74 16                	je     80106a83 <trap+0x22a>
80106a6d:	8b 45 08             	mov    0x8(%ebp),%eax
80106a70:	8b 40 3c             	mov    0x3c(%eax),%eax
80106a73:	0f b7 c0             	movzwl %ax,%eax
80106a76:	83 e0 03             	and    $0x3,%eax
80106a79:	83 f8 03             	cmp    $0x3,%eax
80106a7c:	75 05                	jne    80106a83 <trap+0x22a>
    exit();
80106a7e:	e8 9b db ff ff       	call   8010461e <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106a83:	e8 27 d7 ff ff       	call   801041af <myproc>
80106a88:	85 c0                	test   %eax,%eax
80106a8a:	74 1d                	je     80106aa9 <trap+0x250>
80106a8c:	e8 1e d7 ff ff       	call   801041af <myproc>
80106a91:	8b 40 0c             	mov    0xc(%eax),%eax
80106a94:	83 f8 04             	cmp    $0x4,%eax
80106a97:	75 10                	jne    80106aa9 <trap+0x250>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106a99:	8b 45 08             	mov    0x8(%ebp),%eax
80106a9c:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106a9f:	83 f8 20             	cmp    $0x20,%eax
80106aa2:	75 05                	jne    80106aa9 <trap+0x250>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();
80106aa4:	e8 e4 de ff ff       	call   8010498d <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106aa9:	e8 01 d7 ff ff       	call   801041af <myproc>
80106aae:	85 c0                	test   %eax,%eax
80106ab0:	74 22                	je     80106ad4 <trap+0x27b>
80106ab2:	e8 f8 d6 ff ff       	call   801041af <myproc>
80106ab7:	8b 40 24             	mov    0x24(%eax),%eax
80106aba:	85 c0                	test   %eax,%eax
80106abc:	74 16                	je     80106ad4 <trap+0x27b>
80106abe:	8b 45 08             	mov    0x8(%ebp),%eax
80106ac1:	8b 40 3c             	mov    0x3c(%eax),%eax
80106ac4:	0f b7 c0             	movzwl %ax,%eax
80106ac7:	83 e0 03             	and    $0x3,%eax
80106aca:	83 f8 03             	cmp    $0x3,%eax
80106acd:	75 05                	jne    80106ad4 <trap+0x27b>
    exit();
80106acf:	e8 4a db ff ff       	call   8010461e <exit>
}
80106ad4:	83 c4 4c             	add    $0x4c,%esp
80106ad7:	5b                   	pop    %ebx
80106ad8:	5e                   	pop    %esi
80106ad9:	5f                   	pop    %edi
80106ada:	5d                   	pop    %ebp
80106adb:	c3                   	ret    

80106adc <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106adc:	55                   	push   %ebp
80106add:	89 e5                	mov    %esp,%ebp
80106adf:	83 ec 14             	sub    $0x14,%esp
80106ae2:	8b 45 08             	mov    0x8(%ebp),%eax
80106ae5:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106ae9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106aec:	89 c2                	mov    %eax,%edx
80106aee:	ec                   	in     (%dx),%al
80106aef:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106af2:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80106af5:	c9                   	leave  
80106af6:	c3                   	ret    

80106af7 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106af7:	55                   	push   %ebp
80106af8:	89 e5                	mov    %esp,%ebp
80106afa:	83 ec 08             	sub    $0x8,%esp
80106afd:	8b 45 08             	mov    0x8(%ebp),%eax
80106b00:	8b 55 0c             	mov    0xc(%ebp),%edx
80106b03:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106b07:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106b0a:	8a 45 f8             	mov    -0x8(%ebp),%al
80106b0d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106b10:	ee                   	out    %al,(%dx)
}
80106b11:	c9                   	leave  
80106b12:	c3                   	ret    

80106b13 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106b13:	55                   	push   %ebp
80106b14:	89 e5                	mov    %esp,%ebp
80106b16:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106b19:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106b20:	00 
80106b21:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106b28:	e8 ca ff ff ff       	call   80106af7 <outb>

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106b2d:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80106b34:	00 
80106b35:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106b3c:	e8 b6 ff ff ff       	call   80106af7 <outb>
  outb(COM1+0, 115200/9600);
80106b41:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80106b48:	00 
80106b49:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106b50:	e8 a2 ff ff ff       	call   80106af7 <outb>
  outb(COM1+1, 0);
80106b55:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106b5c:	00 
80106b5d:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106b64:	e8 8e ff ff ff       	call   80106af7 <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106b69:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106b70:	00 
80106b71:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106b78:	e8 7a ff ff ff       	call   80106af7 <outb>
  outb(COM1+4, 0);
80106b7d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106b84:	00 
80106b85:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80106b8c:	e8 66 ff ff ff       	call   80106af7 <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106b91:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106b98:	00 
80106b99:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106ba0:	e8 52 ff ff ff       	call   80106af7 <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106ba5:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106bac:	e8 2b ff ff ff       	call   80106adc <inb>
80106bb1:	3c ff                	cmp    $0xff,%al
80106bb3:	75 02                	jne    80106bb7 <uartinit+0xa4>
    return;
80106bb5:	eb 5b                	jmp    80106c12 <uartinit+0xff>
  uart = 1;
80106bb7:	c7 05 c4 b8 10 80 01 	movl   $0x1,0x8010b8c4
80106bbe:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106bc1:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106bc8:	e8 0f ff ff ff       	call   80106adc <inb>
  inb(COM1+0);
80106bcd:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106bd4:	e8 03 ff ff ff       	call   80106adc <inb>
  ioapicenable(IRQ_COM1, 0);
80106bd9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106be0:	00 
80106be1:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106be8:	e8 96 be ff ff       	call   80102a83 <ioapicenable>

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106bed:	c7 45 f4 d4 8d 10 80 	movl   $0x80108dd4,-0xc(%ebp)
80106bf4:	eb 13                	jmp    80106c09 <uartinit+0xf6>
    uartputc(*p);
80106bf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bf9:	8a 00                	mov    (%eax),%al
80106bfb:	0f be c0             	movsbl %al,%eax
80106bfe:	89 04 24             	mov    %eax,(%esp)
80106c01:	e8 0e 00 00 00       	call   80106c14 <uartputc>
  inb(COM1+2);
  inb(COM1+0);
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106c06:	ff 45 f4             	incl   -0xc(%ebp)
80106c09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c0c:	8a 00                	mov    (%eax),%al
80106c0e:	84 c0                	test   %al,%al
80106c10:	75 e4                	jne    80106bf6 <uartinit+0xe3>
    uartputc(*p);
}
80106c12:	c9                   	leave  
80106c13:	c3                   	ret    

80106c14 <uartputc>:

void
uartputc(int c)
{
80106c14:	55                   	push   %ebp
80106c15:	89 e5                	mov    %esp,%ebp
80106c17:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80106c1a:	a1 c4 b8 10 80       	mov    0x8010b8c4,%eax
80106c1f:	85 c0                	test   %eax,%eax
80106c21:	75 02                	jne    80106c25 <uartputc+0x11>
    return;
80106c23:	eb 4a                	jmp    80106c6f <uartputc+0x5b>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106c25:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106c2c:	eb 0f                	jmp    80106c3d <uartputc+0x29>
    microdelay(10);
80106c2e:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80106c35:	e8 7a c3 ff ff       	call   80102fb4 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106c3a:	ff 45 f4             	incl   -0xc(%ebp)
80106c3d:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106c41:	7f 16                	jg     80106c59 <uartputc+0x45>
80106c43:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106c4a:	e8 8d fe ff ff       	call   80106adc <inb>
80106c4f:	0f b6 c0             	movzbl %al,%eax
80106c52:	83 e0 20             	and    $0x20,%eax
80106c55:	85 c0                	test   %eax,%eax
80106c57:	74 d5                	je     80106c2e <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
80106c59:	8b 45 08             	mov    0x8(%ebp),%eax
80106c5c:	0f b6 c0             	movzbl %al,%eax
80106c5f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c63:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106c6a:	e8 88 fe ff ff       	call   80106af7 <outb>
}
80106c6f:	c9                   	leave  
80106c70:	c3                   	ret    

80106c71 <uartgetc>:

static int
uartgetc(void)
{
80106c71:	55                   	push   %ebp
80106c72:	89 e5                	mov    %esp,%ebp
80106c74:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80106c77:	a1 c4 b8 10 80       	mov    0x8010b8c4,%eax
80106c7c:	85 c0                	test   %eax,%eax
80106c7e:	75 07                	jne    80106c87 <uartgetc+0x16>
    return -1;
80106c80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c85:	eb 2c                	jmp    80106cb3 <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80106c87:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106c8e:	e8 49 fe ff ff       	call   80106adc <inb>
80106c93:	0f b6 c0             	movzbl %al,%eax
80106c96:	83 e0 01             	and    $0x1,%eax
80106c99:	85 c0                	test   %eax,%eax
80106c9b:	75 07                	jne    80106ca4 <uartgetc+0x33>
    return -1;
80106c9d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ca2:	eb 0f                	jmp    80106cb3 <uartgetc+0x42>
  return inb(COM1+0);
80106ca4:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106cab:	e8 2c fe ff ff       	call   80106adc <inb>
80106cb0:	0f b6 c0             	movzbl %al,%eax
}
80106cb3:	c9                   	leave  
80106cb4:	c3                   	ret    

80106cb5 <uartintr>:

void
uartintr(void)
{
80106cb5:	55                   	push   %ebp
80106cb6:	89 e5                	mov    %esp,%ebp
80106cb8:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80106cbb:	c7 04 24 71 6c 10 80 	movl   $0x80106c71,(%esp)
80106cc2:	e8 2e 9b ff ff       	call   801007f5 <consoleintr>
}
80106cc7:	c9                   	leave  
80106cc8:	c3                   	ret    
80106cc9:	00 00                	add    %al,(%eax)
	...

80106ccc <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106ccc:	6a 00                	push   $0x0
  pushl $0
80106cce:	6a 00                	push   $0x0
  jmp alltraps
80106cd0:	e9 af f9 ff ff       	jmp    80106684 <alltraps>

80106cd5 <vector1>:
.globl vector1
vector1:
  pushl $0
80106cd5:	6a 00                	push   $0x0
  pushl $1
80106cd7:	6a 01                	push   $0x1
  jmp alltraps
80106cd9:	e9 a6 f9 ff ff       	jmp    80106684 <alltraps>

80106cde <vector2>:
.globl vector2
vector2:
  pushl $0
80106cde:	6a 00                	push   $0x0
  pushl $2
80106ce0:	6a 02                	push   $0x2
  jmp alltraps
80106ce2:	e9 9d f9 ff ff       	jmp    80106684 <alltraps>

80106ce7 <vector3>:
.globl vector3
vector3:
  pushl $0
80106ce7:	6a 00                	push   $0x0
  pushl $3
80106ce9:	6a 03                	push   $0x3
  jmp alltraps
80106ceb:	e9 94 f9 ff ff       	jmp    80106684 <alltraps>

80106cf0 <vector4>:
.globl vector4
vector4:
  pushl $0
80106cf0:	6a 00                	push   $0x0
  pushl $4
80106cf2:	6a 04                	push   $0x4
  jmp alltraps
80106cf4:	e9 8b f9 ff ff       	jmp    80106684 <alltraps>

80106cf9 <vector5>:
.globl vector5
vector5:
  pushl $0
80106cf9:	6a 00                	push   $0x0
  pushl $5
80106cfb:	6a 05                	push   $0x5
  jmp alltraps
80106cfd:	e9 82 f9 ff ff       	jmp    80106684 <alltraps>

80106d02 <vector6>:
.globl vector6
vector6:
  pushl $0
80106d02:	6a 00                	push   $0x0
  pushl $6
80106d04:	6a 06                	push   $0x6
  jmp alltraps
80106d06:	e9 79 f9 ff ff       	jmp    80106684 <alltraps>

80106d0b <vector7>:
.globl vector7
vector7:
  pushl $0
80106d0b:	6a 00                	push   $0x0
  pushl $7
80106d0d:	6a 07                	push   $0x7
  jmp alltraps
80106d0f:	e9 70 f9 ff ff       	jmp    80106684 <alltraps>

80106d14 <vector8>:
.globl vector8
vector8:
  pushl $8
80106d14:	6a 08                	push   $0x8
  jmp alltraps
80106d16:	e9 69 f9 ff ff       	jmp    80106684 <alltraps>

80106d1b <vector9>:
.globl vector9
vector9:
  pushl $0
80106d1b:	6a 00                	push   $0x0
  pushl $9
80106d1d:	6a 09                	push   $0x9
  jmp alltraps
80106d1f:	e9 60 f9 ff ff       	jmp    80106684 <alltraps>

80106d24 <vector10>:
.globl vector10
vector10:
  pushl $10
80106d24:	6a 0a                	push   $0xa
  jmp alltraps
80106d26:	e9 59 f9 ff ff       	jmp    80106684 <alltraps>

80106d2b <vector11>:
.globl vector11
vector11:
  pushl $11
80106d2b:	6a 0b                	push   $0xb
  jmp alltraps
80106d2d:	e9 52 f9 ff ff       	jmp    80106684 <alltraps>

80106d32 <vector12>:
.globl vector12
vector12:
  pushl $12
80106d32:	6a 0c                	push   $0xc
  jmp alltraps
80106d34:	e9 4b f9 ff ff       	jmp    80106684 <alltraps>

80106d39 <vector13>:
.globl vector13
vector13:
  pushl $13
80106d39:	6a 0d                	push   $0xd
  jmp alltraps
80106d3b:	e9 44 f9 ff ff       	jmp    80106684 <alltraps>

80106d40 <vector14>:
.globl vector14
vector14:
  pushl $14
80106d40:	6a 0e                	push   $0xe
  jmp alltraps
80106d42:	e9 3d f9 ff ff       	jmp    80106684 <alltraps>

80106d47 <vector15>:
.globl vector15
vector15:
  pushl $0
80106d47:	6a 00                	push   $0x0
  pushl $15
80106d49:	6a 0f                	push   $0xf
  jmp alltraps
80106d4b:	e9 34 f9 ff ff       	jmp    80106684 <alltraps>

80106d50 <vector16>:
.globl vector16
vector16:
  pushl $0
80106d50:	6a 00                	push   $0x0
  pushl $16
80106d52:	6a 10                	push   $0x10
  jmp alltraps
80106d54:	e9 2b f9 ff ff       	jmp    80106684 <alltraps>

80106d59 <vector17>:
.globl vector17
vector17:
  pushl $17
80106d59:	6a 11                	push   $0x11
  jmp alltraps
80106d5b:	e9 24 f9 ff ff       	jmp    80106684 <alltraps>

80106d60 <vector18>:
.globl vector18
vector18:
  pushl $0
80106d60:	6a 00                	push   $0x0
  pushl $18
80106d62:	6a 12                	push   $0x12
  jmp alltraps
80106d64:	e9 1b f9 ff ff       	jmp    80106684 <alltraps>

80106d69 <vector19>:
.globl vector19
vector19:
  pushl $0
80106d69:	6a 00                	push   $0x0
  pushl $19
80106d6b:	6a 13                	push   $0x13
  jmp alltraps
80106d6d:	e9 12 f9 ff ff       	jmp    80106684 <alltraps>

80106d72 <vector20>:
.globl vector20
vector20:
  pushl $0
80106d72:	6a 00                	push   $0x0
  pushl $20
80106d74:	6a 14                	push   $0x14
  jmp alltraps
80106d76:	e9 09 f9 ff ff       	jmp    80106684 <alltraps>

80106d7b <vector21>:
.globl vector21
vector21:
  pushl $0
80106d7b:	6a 00                	push   $0x0
  pushl $21
80106d7d:	6a 15                	push   $0x15
  jmp alltraps
80106d7f:	e9 00 f9 ff ff       	jmp    80106684 <alltraps>

80106d84 <vector22>:
.globl vector22
vector22:
  pushl $0
80106d84:	6a 00                	push   $0x0
  pushl $22
80106d86:	6a 16                	push   $0x16
  jmp alltraps
80106d88:	e9 f7 f8 ff ff       	jmp    80106684 <alltraps>

80106d8d <vector23>:
.globl vector23
vector23:
  pushl $0
80106d8d:	6a 00                	push   $0x0
  pushl $23
80106d8f:	6a 17                	push   $0x17
  jmp alltraps
80106d91:	e9 ee f8 ff ff       	jmp    80106684 <alltraps>

80106d96 <vector24>:
.globl vector24
vector24:
  pushl $0
80106d96:	6a 00                	push   $0x0
  pushl $24
80106d98:	6a 18                	push   $0x18
  jmp alltraps
80106d9a:	e9 e5 f8 ff ff       	jmp    80106684 <alltraps>

80106d9f <vector25>:
.globl vector25
vector25:
  pushl $0
80106d9f:	6a 00                	push   $0x0
  pushl $25
80106da1:	6a 19                	push   $0x19
  jmp alltraps
80106da3:	e9 dc f8 ff ff       	jmp    80106684 <alltraps>

80106da8 <vector26>:
.globl vector26
vector26:
  pushl $0
80106da8:	6a 00                	push   $0x0
  pushl $26
80106daa:	6a 1a                	push   $0x1a
  jmp alltraps
80106dac:	e9 d3 f8 ff ff       	jmp    80106684 <alltraps>

80106db1 <vector27>:
.globl vector27
vector27:
  pushl $0
80106db1:	6a 00                	push   $0x0
  pushl $27
80106db3:	6a 1b                	push   $0x1b
  jmp alltraps
80106db5:	e9 ca f8 ff ff       	jmp    80106684 <alltraps>

80106dba <vector28>:
.globl vector28
vector28:
  pushl $0
80106dba:	6a 00                	push   $0x0
  pushl $28
80106dbc:	6a 1c                	push   $0x1c
  jmp alltraps
80106dbe:	e9 c1 f8 ff ff       	jmp    80106684 <alltraps>

80106dc3 <vector29>:
.globl vector29
vector29:
  pushl $0
80106dc3:	6a 00                	push   $0x0
  pushl $29
80106dc5:	6a 1d                	push   $0x1d
  jmp alltraps
80106dc7:	e9 b8 f8 ff ff       	jmp    80106684 <alltraps>

80106dcc <vector30>:
.globl vector30
vector30:
  pushl $0
80106dcc:	6a 00                	push   $0x0
  pushl $30
80106dce:	6a 1e                	push   $0x1e
  jmp alltraps
80106dd0:	e9 af f8 ff ff       	jmp    80106684 <alltraps>

80106dd5 <vector31>:
.globl vector31
vector31:
  pushl $0
80106dd5:	6a 00                	push   $0x0
  pushl $31
80106dd7:	6a 1f                	push   $0x1f
  jmp alltraps
80106dd9:	e9 a6 f8 ff ff       	jmp    80106684 <alltraps>

80106dde <vector32>:
.globl vector32
vector32:
  pushl $0
80106dde:	6a 00                	push   $0x0
  pushl $32
80106de0:	6a 20                	push   $0x20
  jmp alltraps
80106de2:	e9 9d f8 ff ff       	jmp    80106684 <alltraps>

80106de7 <vector33>:
.globl vector33
vector33:
  pushl $0
80106de7:	6a 00                	push   $0x0
  pushl $33
80106de9:	6a 21                	push   $0x21
  jmp alltraps
80106deb:	e9 94 f8 ff ff       	jmp    80106684 <alltraps>

80106df0 <vector34>:
.globl vector34
vector34:
  pushl $0
80106df0:	6a 00                	push   $0x0
  pushl $34
80106df2:	6a 22                	push   $0x22
  jmp alltraps
80106df4:	e9 8b f8 ff ff       	jmp    80106684 <alltraps>

80106df9 <vector35>:
.globl vector35
vector35:
  pushl $0
80106df9:	6a 00                	push   $0x0
  pushl $35
80106dfb:	6a 23                	push   $0x23
  jmp alltraps
80106dfd:	e9 82 f8 ff ff       	jmp    80106684 <alltraps>

80106e02 <vector36>:
.globl vector36
vector36:
  pushl $0
80106e02:	6a 00                	push   $0x0
  pushl $36
80106e04:	6a 24                	push   $0x24
  jmp alltraps
80106e06:	e9 79 f8 ff ff       	jmp    80106684 <alltraps>

80106e0b <vector37>:
.globl vector37
vector37:
  pushl $0
80106e0b:	6a 00                	push   $0x0
  pushl $37
80106e0d:	6a 25                	push   $0x25
  jmp alltraps
80106e0f:	e9 70 f8 ff ff       	jmp    80106684 <alltraps>

80106e14 <vector38>:
.globl vector38
vector38:
  pushl $0
80106e14:	6a 00                	push   $0x0
  pushl $38
80106e16:	6a 26                	push   $0x26
  jmp alltraps
80106e18:	e9 67 f8 ff ff       	jmp    80106684 <alltraps>

80106e1d <vector39>:
.globl vector39
vector39:
  pushl $0
80106e1d:	6a 00                	push   $0x0
  pushl $39
80106e1f:	6a 27                	push   $0x27
  jmp alltraps
80106e21:	e9 5e f8 ff ff       	jmp    80106684 <alltraps>

80106e26 <vector40>:
.globl vector40
vector40:
  pushl $0
80106e26:	6a 00                	push   $0x0
  pushl $40
80106e28:	6a 28                	push   $0x28
  jmp alltraps
80106e2a:	e9 55 f8 ff ff       	jmp    80106684 <alltraps>

80106e2f <vector41>:
.globl vector41
vector41:
  pushl $0
80106e2f:	6a 00                	push   $0x0
  pushl $41
80106e31:	6a 29                	push   $0x29
  jmp alltraps
80106e33:	e9 4c f8 ff ff       	jmp    80106684 <alltraps>

80106e38 <vector42>:
.globl vector42
vector42:
  pushl $0
80106e38:	6a 00                	push   $0x0
  pushl $42
80106e3a:	6a 2a                	push   $0x2a
  jmp alltraps
80106e3c:	e9 43 f8 ff ff       	jmp    80106684 <alltraps>

80106e41 <vector43>:
.globl vector43
vector43:
  pushl $0
80106e41:	6a 00                	push   $0x0
  pushl $43
80106e43:	6a 2b                	push   $0x2b
  jmp alltraps
80106e45:	e9 3a f8 ff ff       	jmp    80106684 <alltraps>

80106e4a <vector44>:
.globl vector44
vector44:
  pushl $0
80106e4a:	6a 00                	push   $0x0
  pushl $44
80106e4c:	6a 2c                	push   $0x2c
  jmp alltraps
80106e4e:	e9 31 f8 ff ff       	jmp    80106684 <alltraps>

80106e53 <vector45>:
.globl vector45
vector45:
  pushl $0
80106e53:	6a 00                	push   $0x0
  pushl $45
80106e55:	6a 2d                	push   $0x2d
  jmp alltraps
80106e57:	e9 28 f8 ff ff       	jmp    80106684 <alltraps>

80106e5c <vector46>:
.globl vector46
vector46:
  pushl $0
80106e5c:	6a 00                	push   $0x0
  pushl $46
80106e5e:	6a 2e                	push   $0x2e
  jmp alltraps
80106e60:	e9 1f f8 ff ff       	jmp    80106684 <alltraps>

80106e65 <vector47>:
.globl vector47
vector47:
  pushl $0
80106e65:	6a 00                	push   $0x0
  pushl $47
80106e67:	6a 2f                	push   $0x2f
  jmp alltraps
80106e69:	e9 16 f8 ff ff       	jmp    80106684 <alltraps>

80106e6e <vector48>:
.globl vector48
vector48:
  pushl $0
80106e6e:	6a 00                	push   $0x0
  pushl $48
80106e70:	6a 30                	push   $0x30
  jmp alltraps
80106e72:	e9 0d f8 ff ff       	jmp    80106684 <alltraps>

80106e77 <vector49>:
.globl vector49
vector49:
  pushl $0
80106e77:	6a 00                	push   $0x0
  pushl $49
80106e79:	6a 31                	push   $0x31
  jmp alltraps
80106e7b:	e9 04 f8 ff ff       	jmp    80106684 <alltraps>

80106e80 <vector50>:
.globl vector50
vector50:
  pushl $0
80106e80:	6a 00                	push   $0x0
  pushl $50
80106e82:	6a 32                	push   $0x32
  jmp alltraps
80106e84:	e9 fb f7 ff ff       	jmp    80106684 <alltraps>

80106e89 <vector51>:
.globl vector51
vector51:
  pushl $0
80106e89:	6a 00                	push   $0x0
  pushl $51
80106e8b:	6a 33                	push   $0x33
  jmp alltraps
80106e8d:	e9 f2 f7 ff ff       	jmp    80106684 <alltraps>

80106e92 <vector52>:
.globl vector52
vector52:
  pushl $0
80106e92:	6a 00                	push   $0x0
  pushl $52
80106e94:	6a 34                	push   $0x34
  jmp alltraps
80106e96:	e9 e9 f7 ff ff       	jmp    80106684 <alltraps>

80106e9b <vector53>:
.globl vector53
vector53:
  pushl $0
80106e9b:	6a 00                	push   $0x0
  pushl $53
80106e9d:	6a 35                	push   $0x35
  jmp alltraps
80106e9f:	e9 e0 f7 ff ff       	jmp    80106684 <alltraps>

80106ea4 <vector54>:
.globl vector54
vector54:
  pushl $0
80106ea4:	6a 00                	push   $0x0
  pushl $54
80106ea6:	6a 36                	push   $0x36
  jmp alltraps
80106ea8:	e9 d7 f7 ff ff       	jmp    80106684 <alltraps>

80106ead <vector55>:
.globl vector55
vector55:
  pushl $0
80106ead:	6a 00                	push   $0x0
  pushl $55
80106eaf:	6a 37                	push   $0x37
  jmp alltraps
80106eb1:	e9 ce f7 ff ff       	jmp    80106684 <alltraps>

80106eb6 <vector56>:
.globl vector56
vector56:
  pushl $0
80106eb6:	6a 00                	push   $0x0
  pushl $56
80106eb8:	6a 38                	push   $0x38
  jmp alltraps
80106eba:	e9 c5 f7 ff ff       	jmp    80106684 <alltraps>

80106ebf <vector57>:
.globl vector57
vector57:
  pushl $0
80106ebf:	6a 00                	push   $0x0
  pushl $57
80106ec1:	6a 39                	push   $0x39
  jmp alltraps
80106ec3:	e9 bc f7 ff ff       	jmp    80106684 <alltraps>

80106ec8 <vector58>:
.globl vector58
vector58:
  pushl $0
80106ec8:	6a 00                	push   $0x0
  pushl $58
80106eca:	6a 3a                	push   $0x3a
  jmp alltraps
80106ecc:	e9 b3 f7 ff ff       	jmp    80106684 <alltraps>

80106ed1 <vector59>:
.globl vector59
vector59:
  pushl $0
80106ed1:	6a 00                	push   $0x0
  pushl $59
80106ed3:	6a 3b                	push   $0x3b
  jmp alltraps
80106ed5:	e9 aa f7 ff ff       	jmp    80106684 <alltraps>

80106eda <vector60>:
.globl vector60
vector60:
  pushl $0
80106eda:	6a 00                	push   $0x0
  pushl $60
80106edc:	6a 3c                	push   $0x3c
  jmp alltraps
80106ede:	e9 a1 f7 ff ff       	jmp    80106684 <alltraps>

80106ee3 <vector61>:
.globl vector61
vector61:
  pushl $0
80106ee3:	6a 00                	push   $0x0
  pushl $61
80106ee5:	6a 3d                	push   $0x3d
  jmp alltraps
80106ee7:	e9 98 f7 ff ff       	jmp    80106684 <alltraps>

80106eec <vector62>:
.globl vector62
vector62:
  pushl $0
80106eec:	6a 00                	push   $0x0
  pushl $62
80106eee:	6a 3e                	push   $0x3e
  jmp alltraps
80106ef0:	e9 8f f7 ff ff       	jmp    80106684 <alltraps>

80106ef5 <vector63>:
.globl vector63
vector63:
  pushl $0
80106ef5:	6a 00                	push   $0x0
  pushl $63
80106ef7:	6a 3f                	push   $0x3f
  jmp alltraps
80106ef9:	e9 86 f7 ff ff       	jmp    80106684 <alltraps>

80106efe <vector64>:
.globl vector64
vector64:
  pushl $0
80106efe:	6a 00                	push   $0x0
  pushl $64
80106f00:	6a 40                	push   $0x40
  jmp alltraps
80106f02:	e9 7d f7 ff ff       	jmp    80106684 <alltraps>

80106f07 <vector65>:
.globl vector65
vector65:
  pushl $0
80106f07:	6a 00                	push   $0x0
  pushl $65
80106f09:	6a 41                	push   $0x41
  jmp alltraps
80106f0b:	e9 74 f7 ff ff       	jmp    80106684 <alltraps>

80106f10 <vector66>:
.globl vector66
vector66:
  pushl $0
80106f10:	6a 00                	push   $0x0
  pushl $66
80106f12:	6a 42                	push   $0x42
  jmp alltraps
80106f14:	e9 6b f7 ff ff       	jmp    80106684 <alltraps>

80106f19 <vector67>:
.globl vector67
vector67:
  pushl $0
80106f19:	6a 00                	push   $0x0
  pushl $67
80106f1b:	6a 43                	push   $0x43
  jmp alltraps
80106f1d:	e9 62 f7 ff ff       	jmp    80106684 <alltraps>

80106f22 <vector68>:
.globl vector68
vector68:
  pushl $0
80106f22:	6a 00                	push   $0x0
  pushl $68
80106f24:	6a 44                	push   $0x44
  jmp alltraps
80106f26:	e9 59 f7 ff ff       	jmp    80106684 <alltraps>

80106f2b <vector69>:
.globl vector69
vector69:
  pushl $0
80106f2b:	6a 00                	push   $0x0
  pushl $69
80106f2d:	6a 45                	push   $0x45
  jmp alltraps
80106f2f:	e9 50 f7 ff ff       	jmp    80106684 <alltraps>

80106f34 <vector70>:
.globl vector70
vector70:
  pushl $0
80106f34:	6a 00                	push   $0x0
  pushl $70
80106f36:	6a 46                	push   $0x46
  jmp alltraps
80106f38:	e9 47 f7 ff ff       	jmp    80106684 <alltraps>

80106f3d <vector71>:
.globl vector71
vector71:
  pushl $0
80106f3d:	6a 00                	push   $0x0
  pushl $71
80106f3f:	6a 47                	push   $0x47
  jmp alltraps
80106f41:	e9 3e f7 ff ff       	jmp    80106684 <alltraps>

80106f46 <vector72>:
.globl vector72
vector72:
  pushl $0
80106f46:	6a 00                	push   $0x0
  pushl $72
80106f48:	6a 48                	push   $0x48
  jmp alltraps
80106f4a:	e9 35 f7 ff ff       	jmp    80106684 <alltraps>

80106f4f <vector73>:
.globl vector73
vector73:
  pushl $0
80106f4f:	6a 00                	push   $0x0
  pushl $73
80106f51:	6a 49                	push   $0x49
  jmp alltraps
80106f53:	e9 2c f7 ff ff       	jmp    80106684 <alltraps>

80106f58 <vector74>:
.globl vector74
vector74:
  pushl $0
80106f58:	6a 00                	push   $0x0
  pushl $74
80106f5a:	6a 4a                	push   $0x4a
  jmp alltraps
80106f5c:	e9 23 f7 ff ff       	jmp    80106684 <alltraps>

80106f61 <vector75>:
.globl vector75
vector75:
  pushl $0
80106f61:	6a 00                	push   $0x0
  pushl $75
80106f63:	6a 4b                	push   $0x4b
  jmp alltraps
80106f65:	e9 1a f7 ff ff       	jmp    80106684 <alltraps>

80106f6a <vector76>:
.globl vector76
vector76:
  pushl $0
80106f6a:	6a 00                	push   $0x0
  pushl $76
80106f6c:	6a 4c                	push   $0x4c
  jmp alltraps
80106f6e:	e9 11 f7 ff ff       	jmp    80106684 <alltraps>

80106f73 <vector77>:
.globl vector77
vector77:
  pushl $0
80106f73:	6a 00                	push   $0x0
  pushl $77
80106f75:	6a 4d                	push   $0x4d
  jmp alltraps
80106f77:	e9 08 f7 ff ff       	jmp    80106684 <alltraps>

80106f7c <vector78>:
.globl vector78
vector78:
  pushl $0
80106f7c:	6a 00                	push   $0x0
  pushl $78
80106f7e:	6a 4e                	push   $0x4e
  jmp alltraps
80106f80:	e9 ff f6 ff ff       	jmp    80106684 <alltraps>

80106f85 <vector79>:
.globl vector79
vector79:
  pushl $0
80106f85:	6a 00                	push   $0x0
  pushl $79
80106f87:	6a 4f                	push   $0x4f
  jmp alltraps
80106f89:	e9 f6 f6 ff ff       	jmp    80106684 <alltraps>

80106f8e <vector80>:
.globl vector80
vector80:
  pushl $0
80106f8e:	6a 00                	push   $0x0
  pushl $80
80106f90:	6a 50                	push   $0x50
  jmp alltraps
80106f92:	e9 ed f6 ff ff       	jmp    80106684 <alltraps>

80106f97 <vector81>:
.globl vector81
vector81:
  pushl $0
80106f97:	6a 00                	push   $0x0
  pushl $81
80106f99:	6a 51                	push   $0x51
  jmp alltraps
80106f9b:	e9 e4 f6 ff ff       	jmp    80106684 <alltraps>

80106fa0 <vector82>:
.globl vector82
vector82:
  pushl $0
80106fa0:	6a 00                	push   $0x0
  pushl $82
80106fa2:	6a 52                	push   $0x52
  jmp alltraps
80106fa4:	e9 db f6 ff ff       	jmp    80106684 <alltraps>

80106fa9 <vector83>:
.globl vector83
vector83:
  pushl $0
80106fa9:	6a 00                	push   $0x0
  pushl $83
80106fab:	6a 53                	push   $0x53
  jmp alltraps
80106fad:	e9 d2 f6 ff ff       	jmp    80106684 <alltraps>

80106fb2 <vector84>:
.globl vector84
vector84:
  pushl $0
80106fb2:	6a 00                	push   $0x0
  pushl $84
80106fb4:	6a 54                	push   $0x54
  jmp alltraps
80106fb6:	e9 c9 f6 ff ff       	jmp    80106684 <alltraps>

80106fbb <vector85>:
.globl vector85
vector85:
  pushl $0
80106fbb:	6a 00                	push   $0x0
  pushl $85
80106fbd:	6a 55                	push   $0x55
  jmp alltraps
80106fbf:	e9 c0 f6 ff ff       	jmp    80106684 <alltraps>

80106fc4 <vector86>:
.globl vector86
vector86:
  pushl $0
80106fc4:	6a 00                	push   $0x0
  pushl $86
80106fc6:	6a 56                	push   $0x56
  jmp alltraps
80106fc8:	e9 b7 f6 ff ff       	jmp    80106684 <alltraps>

80106fcd <vector87>:
.globl vector87
vector87:
  pushl $0
80106fcd:	6a 00                	push   $0x0
  pushl $87
80106fcf:	6a 57                	push   $0x57
  jmp alltraps
80106fd1:	e9 ae f6 ff ff       	jmp    80106684 <alltraps>

80106fd6 <vector88>:
.globl vector88
vector88:
  pushl $0
80106fd6:	6a 00                	push   $0x0
  pushl $88
80106fd8:	6a 58                	push   $0x58
  jmp alltraps
80106fda:	e9 a5 f6 ff ff       	jmp    80106684 <alltraps>

80106fdf <vector89>:
.globl vector89
vector89:
  pushl $0
80106fdf:	6a 00                	push   $0x0
  pushl $89
80106fe1:	6a 59                	push   $0x59
  jmp alltraps
80106fe3:	e9 9c f6 ff ff       	jmp    80106684 <alltraps>

80106fe8 <vector90>:
.globl vector90
vector90:
  pushl $0
80106fe8:	6a 00                	push   $0x0
  pushl $90
80106fea:	6a 5a                	push   $0x5a
  jmp alltraps
80106fec:	e9 93 f6 ff ff       	jmp    80106684 <alltraps>

80106ff1 <vector91>:
.globl vector91
vector91:
  pushl $0
80106ff1:	6a 00                	push   $0x0
  pushl $91
80106ff3:	6a 5b                	push   $0x5b
  jmp alltraps
80106ff5:	e9 8a f6 ff ff       	jmp    80106684 <alltraps>

80106ffa <vector92>:
.globl vector92
vector92:
  pushl $0
80106ffa:	6a 00                	push   $0x0
  pushl $92
80106ffc:	6a 5c                	push   $0x5c
  jmp alltraps
80106ffe:	e9 81 f6 ff ff       	jmp    80106684 <alltraps>

80107003 <vector93>:
.globl vector93
vector93:
  pushl $0
80107003:	6a 00                	push   $0x0
  pushl $93
80107005:	6a 5d                	push   $0x5d
  jmp alltraps
80107007:	e9 78 f6 ff ff       	jmp    80106684 <alltraps>

8010700c <vector94>:
.globl vector94
vector94:
  pushl $0
8010700c:	6a 00                	push   $0x0
  pushl $94
8010700e:	6a 5e                	push   $0x5e
  jmp alltraps
80107010:	e9 6f f6 ff ff       	jmp    80106684 <alltraps>

80107015 <vector95>:
.globl vector95
vector95:
  pushl $0
80107015:	6a 00                	push   $0x0
  pushl $95
80107017:	6a 5f                	push   $0x5f
  jmp alltraps
80107019:	e9 66 f6 ff ff       	jmp    80106684 <alltraps>

8010701e <vector96>:
.globl vector96
vector96:
  pushl $0
8010701e:	6a 00                	push   $0x0
  pushl $96
80107020:	6a 60                	push   $0x60
  jmp alltraps
80107022:	e9 5d f6 ff ff       	jmp    80106684 <alltraps>

80107027 <vector97>:
.globl vector97
vector97:
  pushl $0
80107027:	6a 00                	push   $0x0
  pushl $97
80107029:	6a 61                	push   $0x61
  jmp alltraps
8010702b:	e9 54 f6 ff ff       	jmp    80106684 <alltraps>

80107030 <vector98>:
.globl vector98
vector98:
  pushl $0
80107030:	6a 00                	push   $0x0
  pushl $98
80107032:	6a 62                	push   $0x62
  jmp alltraps
80107034:	e9 4b f6 ff ff       	jmp    80106684 <alltraps>

80107039 <vector99>:
.globl vector99
vector99:
  pushl $0
80107039:	6a 00                	push   $0x0
  pushl $99
8010703b:	6a 63                	push   $0x63
  jmp alltraps
8010703d:	e9 42 f6 ff ff       	jmp    80106684 <alltraps>

80107042 <vector100>:
.globl vector100
vector100:
  pushl $0
80107042:	6a 00                	push   $0x0
  pushl $100
80107044:	6a 64                	push   $0x64
  jmp alltraps
80107046:	e9 39 f6 ff ff       	jmp    80106684 <alltraps>

8010704b <vector101>:
.globl vector101
vector101:
  pushl $0
8010704b:	6a 00                	push   $0x0
  pushl $101
8010704d:	6a 65                	push   $0x65
  jmp alltraps
8010704f:	e9 30 f6 ff ff       	jmp    80106684 <alltraps>

80107054 <vector102>:
.globl vector102
vector102:
  pushl $0
80107054:	6a 00                	push   $0x0
  pushl $102
80107056:	6a 66                	push   $0x66
  jmp alltraps
80107058:	e9 27 f6 ff ff       	jmp    80106684 <alltraps>

8010705d <vector103>:
.globl vector103
vector103:
  pushl $0
8010705d:	6a 00                	push   $0x0
  pushl $103
8010705f:	6a 67                	push   $0x67
  jmp alltraps
80107061:	e9 1e f6 ff ff       	jmp    80106684 <alltraps>

80107066 <vector104>:
.globl vector104
vector104:
  pushl $0
80107066:	6a 00                	push   $0x0
  pushl $104
80107068:	6a 68                	push   $0x68
  jmp alltraps
8010706a:	e9 15 f6 ff ff       	jmp    80106684 <alltraps>

8010706f <vector105>:
.globl vector105
vector105:
  pushl $0
8010706f:	6a 00                	push   $0x0
  pushl $105
80107071:	6a 69                	push   $0x69
  jmp alltraps
80107073:	e9 0c f6 ff ff       	jmp    80106684 <alltraps>

80107078 <vector106>:
.globl vector106
vector106:
  pushl $0
80107078:	6a 00                	push   $0x0
  pushl $106
8010707a:	6a 6a                	push   $0x6a
  jmp alltraps
8010707c:	e9 03 f6 ff ff       	jmp    80106684 <alltraps>

80107081 <vector107>:
.globl vector107
vector107:
  pushl $0
80107081:	6a 00                	push   $0x0
  pushl $107
80107083:	6a 6b                	push   $0x6b
  jmp alltraps
80107085:	e9 fa f5 ff ff       	jmp    80106684 <alltraps>

8010708a <vector108>:
.globl vector108
vector108:
  pushl $0
8010708a:	6a 00                	push   $0x0
  pushl $108
8010708c:	6a 6c                	push   $0x6c
  jmp alltraps
8010708e:	e9 f1 f5 ff ff       	jmp    80106684 <alltraps>

80107093 <vector109>:
.globl vector109
vector109:
  pushl $0
80107093:	6a 00                	push   $0x0
  pushl $109
80107095:	6a 6d                	push   $0x6d
  jmp alltraps
80107097:	e9 e8 f5 ff ff       	jmp    80106684 <alltraps>

8010709c <vector110>:
.globl vector110
vector110:
  pushl $0
8010709c:	6a 00                	push   $0x0
  pushl $110
8010709e:	6a 6e                	push   $0x6e
  jmp alltraps
801070a0:	e9 df f5 ff ff       	jmp    80106684 <alltraps>

801070a5 <vector111>:
.globl vector111
vector111:
  pushl $0
801070a5:	6a 00                	push   $0x0
  pushl $111
801070a7:	6a 6f                	push   $0x6f
  jmp alltraps
801070a9:	e9 d6 f5 ff ff       	jmp    80106684 <alltraps>

801070ae <vector112>:
.globl vector112
vector112:
  pushl $0
801070ae:	6a 00                	push   $0x0
  pushl $112
801070b0:	6a 70                	push   $0x70
  jmp alltraps
801070b2:	e9 cd f5 ff ff       	jmp    80106684 <alltraps>

801070b7 <vector113>:
.globl vector113
vector113:
  pushl $0
801070b7:	6a 00                	push   $0x0
  pushl $113
801070b9:	6a 71                	push   $0x71
  jmp alltraps
801070bb:	e9 c4 f5 ff ff       	jmp    80106684 <alltraps>

801070c0 <vector114>:
.globl vector114
vector114:
  pushl $0
801070c0:	6a 00                	push   $0x0
  pushl $114
801070c2:	6a 72                	push   $0x72
  jmp alltraps
801070c4:	e9 bb f5 ff ff       	jmp    80106684 <alltraps>

801070c9 <vector115>:
.globl vector115
vector115:
  pushl $0
801070c9:	6a 00                	push   $0x0
  pushl $115
801070cb:	6a 73                	push   $0x73
  jmp alltraps
801070cd:	e9 b2 f5 ff ff       	jmp    80106684 <alltraps>

801070d2 <vector116>:
.globl vector116
vector116:
  pushl $0
801070d2:	6a 00                	push   $0x0
  pushl $116
801070d4:	6a 74                	push   $0x74
  jmp alltraps
801070d6:	e9 a9 f5 ff ff       	jmp    80106684 <alltraps>

801070db <vector117>:
.globl vector117
vector117:
  pushl $0
801070db:	6a 00                	push   $0x0
  pushl $117
801070dd:	6a 75                	push   $0x75
  jmp alltraps
801070df:	e9 a0 f5 ff ff       	jmp    80106684 <alltraps>

801070e4 <vector118>:
.globl vector118
vector118:
  pushl $0
801070e4:	6a 00                	push   $0x0
  pushl $118
801070e6:	6a 76                	push   $0x76
  jmp alltraps
801070e8:	e9 97 f5 ff ff       	jmp    80106684 <alltraps>

801070ed <vector119>:
.globl vector119
vector119:
  pushl $0
801070ed:	6a 00                	push   $0x0
  pushl $119
801070ef:	6a 77                	push   $0x77
  jmp alltraps
801070f1:	e9 8e f5 ff ff       	jmp    80106684 <alltraps>

801070f6 <vector120>:
.globl vector120
vector120:
  pushl $0
801070f6:	6a 00                	push   $0x0
  pushl $120
801070f8:	6a 78                	push   $0x78
  jmp alltraps
801070fa:	e9 85 f5 ff ff       	jmp    80106684 <alltraps>

801070ff <vector121>:
.globl vector121
vector121:
  pushl $0
801070ff:	6a 00                	push   $0x0
  pushl $121
80107101:	6a 79                	push   $0x79
  jmp alltraps
80107103:	e9 7c f5 ff ff       	jmp    80106684 <alltraps>

80107108 <vector122>:
.globl vector122
vector122:
  pushl $0
80107108:	6a 00                	push   $0x0
  pushl $122
8010710a:	6a 7a                	push   $0x7a
  jmp alltraps
8010710c:	e9 73 f5 ff ff       	jmp    80106684 <alltraps>

80107111 <vector123>:
.globl vector123
vector123:
  pushl $0
80107111:	6a 00                	push   $0x0
  pushl $123
80107113:	6a 7b                	push   $0x7b
  jmp alltraps
80107115:	e9 6a f5 ff ff       	jmp    80106684 <alltraps>

8010711a <vector124>:
.globl vector124
vector124:
  pushl $0
8010711a:	6a 00                	push   $0x0
  pushl $124
8010711c:	6a 7c                	push   $0x7c
  jmp alltraps
8010711e:	e9 61 f5 ff ff       	jmp    80106684 <alltraps>

80107123 <vector125>:
.globl vector125
vector125:
  pushl $0
80107123:	6a 00                	push   $0x0
  pushl $125
80107125:	6a 7d                	push   $0x7d
  jmp alltraps
80107127:	e9 58 f5 ff ff       	jmp    80106684 <alltraps>

8010712c <vector126>:
.globl vector126
vector126:
  pushl $0
8010712c:	6a 00                	push   $0x0
  pushl $126
8010712e:	6a 7e                	push   $0x7e
  jmp alltraps
80107130:	e9 4f f5 ff ff       	jmp    80106684 <alltraps>

80107135 <vector127>:
.globl vector127
vector127:
  pushl $0
80107135:	6a 00                	push   $0x0
  pushl $127
80107137:	6a 7f                	push   $0x7f
  jmp alltraps
80107139:	e9 46 f5 ff ff       	jmp    80106684 <alltraps>

8010713e <vector128>:
.globl vector128
vector128:
  pushl $0
8010713e:	6a 00                	push   $0x0
  pushl $128
80107140:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107145:	e9 3a f5 ff ff       	jmp    80106684 <alltraps>

8010714a <vector129>:
.globl vector129
vector129:
  pushl $0
8010714a:	6a 00                	push   $0x0
  pushl $129
8010714c:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107151:	e9 2e f5 ff ff       	jmp    80106684 <alltraps>

80107156 <vector130>:
.globl vector130
vector130:
  pushl $0
80107156:	6a 00                	push   $0x0
  pushl $130
80107158:	68 82 00 00 00       	push   $0x82
  jmp alltraps
8010715d:	e9 22 f5 ff ff       	jmp    80106684 <alltraps>

80107162 <vector131>:
.globl vector131
vector131:
  pushl $0
80107162:	6a 00                	push   $0x0
  pushl $131
80107164:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107169:	e9 16 f5 ff ff       	jmp    80106684 <alltraps>

8010716e <vector132>:
.globl vector132
vector132:
  pushl $0
8010716e:	6a 00                	push   $0x0
  pushl $132
80107170:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107175:	e9 0a f5 ff ff       	jmp    80106684 <alltraps>

8010717a <vector133>:
.globl vector133
vector133:
  pushl $0
8010717a:	6a 00                	push   $0x0
  pushl $133
8010717c:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107181:	e9 fe f4 ff ff       	jmp    80106684 <alltraps>

80107186 <vector134>:
.globl vector134
vector134:
  pushl $0
80107186:	6a 00                	push   $0x0
  pushl $134
80107188:	68 86 00 00 00       	push   $0x86
  jmp alltraps
8010718d:	e9 f2 f4 ff ff       	jmp    80106684 <alltraps>

80107192 <vector135>:
.globl vector135
vector135:
  pushl $0
80107192:	6a 00                	push   $0x0
  pushl $135
80107194:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107199:	e9 e6 f4 ff ff       	jmp    80106684 <alltraps>

8010719e <vector136>:
.globl vector136
vector136:
  pushl $0
8010719e:	6a 00                	push   $0x0
  pushl $136
801071a0:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801071a5:	e9 da f4 ff ff       	jmp    80106684 <alltraps>

801071aa <vector137>:
.globl vector137
vector137:
  pushl $0
801071aa:	6a 00                	push   $0x0
  pushl $137
801071ac:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801071b1:	e9 ce f4 ff ff       	jmp    80106684 <alltraps>

801071b6 <vector138>:
.globl vector138
vector138:
  pushl $0
801071b6:	6a 00                	push   $0x0
  pushl $138
801071b8:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801071bd:	e9 c2 f4 ff ff       	jmp    80106684 <alltraps>

801071c2 <vector139>:
.globl vector139
vector139:
  pushl $0
801071c2:	6a 00                	push   $0x0
  pushl $139
801071c4:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801071c9:	e9 b6 f4 ff ff       	jmp    80106684 <alltraps>

801071ce <vector140>:
.globl vector140
vector140:
  pushl $0
801071ce:	6a 00                	push   $0x0
  pushl $140
801071d0:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801071d5:	e9 aa f4 ff ff       	jmp    80106684 <alltraps>

801071da <vector141>:
.globl vector141
vector141:
  pushl $0
801071da:	6a 00                	push   $0x0
  pushl $141
801071dc:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801071e1:	e9 9e f4 ff ff       	jmp    80106684 <alltraps>

801071e6 <vector142>:
.globl vector142
vector142:
  pushl $0
801071e6:	6a 00                	push   $0x0
  pushl $142
801071e8:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801071ed:	e9 92 f4 ff ff       	jmp    80106684 <alltraps>

801071f2 <vector143>:
.globl vector143
vector143:
  pushl $0
801071f2:	6a 00                	push   $0x0
  pushl $143
801071f4:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801071f9:	e9 86 f4 ff ff       	jmp    80106684 <alltraps>

801071fe <vector144>:
.globl vector144
vector144:
  pushl $0
801071fe:	6a 00                	push   $0x0
  pushl $144
80107200:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107205:	e9 7a f4 ff ff       	jmp    80106684 <alltraps>

8010720a <vector145>:
.globl vector145
vector145:
  pushl $0
8010720a:	6a 00                	push   $0x0
  pushl $145
8010720c:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107211:	e9 6e f4 ff ff       	jmp    80106684 <alltraps>

80107216 <vector146>:
.globl vector146
vector146:
  pushl $0
80107216:	6a 00                	push   $0x0
  pushl $146
80107218:	68 92 00 00 00       	push   $0x92
  jmp alltraps
8010721d:	e9 62 f4 ff ff       	jmp    80106684 <alltraps>

80107222 <vector147>:
.globl vector147
vector147:
  pushl $0
80107222:	6a 00                	push   $0x0
  pushl $147
80107224:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107229:	e9 56 f4 ff ff       	jmp    80106684 <alltraps>

8010722e <vector148>:
.globl vector148
vector148:
  pushl $0
8010722e:	6a 00                	push   $0x0
  pushl $148
80107230:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107235:	e9 4a f4 ff ff       	jmp    80106684 <alltraps>

8010723a <vector149>:
.globl vector149
vector149:
  pushl $0
8010723a:	6a 00                	push   $0x0
  pushl $149
8010723c:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107241:	e9 3e f4 ff ff       	jmp    80106684 <alltraps>

80107246 <vector150>:
.globl vector150
vector150:
  pushl $0
80107246:	6a 00                	push   $0x0
  pushl $150
80107248:	68 96 00 00 00       	push   $0x96
  jmp alltraps
8010724d:	e9 32 f4 ff ff       	jmp    80106684 <alltraps>

80107252 <vector151>:
.globl vector151
vector151:
  pushl $0
80107252:	6a 00                	push   $0x0
  pushl $151
80107254:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107259:	e9 26 f4 ff ff       	jmp    80106684 <alltraps>

8010725e <vector152>:
.globl vector152
vector152:
  pushl $0
8010725e:	6a 00                	push   $0x0
  pushl $152
80107260:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107265:	e9 1a f4 ff ff       	jmp    80106684 <alltraps>

8010726a <vector153>:
.globl vector153
vector153:
  pushl $0
8010726a:	6a 00                	push   $0x0
  pushl $153
8010726c:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107271:	e9 0e f4 ff ff       	jmp    80106684 <alltraps>

80107276 <vector154>:
.globl vector154
vector154:
  pushl $0
80107276:	6a 00                	push   $0x0
  pushl $154
80107278:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
8010727d:	e9 02 f4 ff ff       	jmp    80106684 <alltraps>

80107282 <vector155>:
.globl vector155
vector155:
  pushl $0
80107282:	6a 00                	push   $0x0
  pushl $155
80107284:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107289:	e9 f6 f3 ff ff       	jmp    80106684 <alltraps>

8010728e <vector156>:
.globl vector156
vector156:
  pushl $0
8010728e:	6a 00                	push   $0x0
  pushl $156
80107290:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107295:	e9 ea f3 ff ff       	jmp    80106684 <alltraps>

8010729a <vector157>:
.globl vector157
vector157:
  pushl $0
8010729a:	6a 00                	push   $0x0
  pushl $157
8010729c:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801072a1:	e9 de f3 ff ff       	jmp    80106684 <alltraps>

801072a6 <vector158>:
.globl vector158
vector158:
  pushl $0
801072a6:	6a 00                	push   $0x0
  pushl $158
801072a8:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801072ad:	e9 d2 f3 ff ff       	jmp    80106684 <alltraps>

801072b2 <vector159>:
.globl vector159
vector159:
  pushl $0
801072b2:	6a 00                	push   $0x0
  pushl $159
801072b4:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801072b9:	e9 c6 f3 ff ff       	jmp    80106684 <alltraps>

801072be <vector160>:
.globl vector160
vector160:
  pushl $0
801072be:	6a 00                	push   $0x0
  pushl $160
801072c0:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801072c5:	e9 ba f3 ff ff       	jmp    80106684 <alltraps>

801072ca <vector161>:
.globl vector161
vector161:
  pushl $0
801072ca:	6a 00                	push   $0x0
  pushl $161
801072cc:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801072d1:	e9 ae f3 ff ff       	jmp    80106684 <alltraps>

801072d6 <vector162>:
.globl vector162
vector162:
  pushl $0
801072d6:	6a 00                	push   $0x0
  pushl $162
801072d8:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801072dd:	e9 a2 f3 ff ff       	jmp    80106684 <alltraps>

801072e2 <vector163>:
.globl vector163
vector163:
  pushl $0
801072e2:	6a 00                	push   $0x0
  pushl $163
801072e4:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801072e9:	e9 96 f3 ff ff       	jmp    80106684 <alltraps>

801072ee <vector164>:
.globl vector164
vector164:
  pushl $0
801072ee:	6a 00                	push   $0x0
  pushl $164
801072f0:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801072f5:	e9 8a f3 ff ff       	jmp    80106684 <alltraps>

801072fa <vector165>:
.globl vector165
vector165:
  pushl $0
801072fa:	6a 00                	push   $0x0
  pushl $165
801072fc:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107301:	e9 7e f3 ff ff       	jmp    80106684 <alltraps>

80107306 <vector166>:
.globl vector166
vector166:
  pushl $0
80107306:	6a 00                	push   $0x0
  pushl $166
80107308:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
8010730d:	e9 72 f3 ff ff       	jmp    80106684 <alltraps>

80107312 <vector167>:
.globl vector167
vector167:
  pushl $0
80107312:	6a 00                	push   $0x0
  pushl $167
80107314:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107319:	e9 66 f3 ff ff       	jmp    80106684 <alltraps>

8010731e <vector168>:
.globl vector168
vector168:
  pushl $0
8010731e:	6a 00                	push   $0x0
  pushl $168
80107320:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107325:	e9 5a f3 ff ff       	jmp    80106684 <alltraps>

8010732a <vector169>:
.globl vector169
vector169:
  pushl $0
8010732a:	6a 00                	push   $0x0
  pushl $169
8010732c:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107331:	e9 4e f3 ff ff       	jmp    80106684 <alltraps>

80107336 <vector170>:
.globl vector170
vector170:
  pushl $0
80107336:	6a 00                	push   $0x0
  pushl $170
80107338:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
8010733d:	e9 42 f3 ff ff       	jmp    80106684 <alltraps>

80107342 <vector171>:
.globl vector171
vector171:
  pushl $0
80107342:	6a 00                	push   $0x0
  pushl $171
80107344:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107349:	e9 36 f3 ff ff       	jmp    80106684 <alltraps>

8010734e <vector172>:
.globl vector172
vector172:
  pushl $0
8010734e:	6a 00                	push   $0x0
  pushl $172
80107350:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107355:	e9 2a f3 ff ff       	jmp    80106684 <alltraps>

8010735a <vector173>:
.globl vector173
vector173:
  pushl $0
8010735a:	6a 00                	push   $0x0
  pushl $173
8010735c:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107361:	e9 1e f3 ff ff       	jmp    80106684 <alltraps>

80107366 <vector174>:
.globl vector174
vector174:
  pushl $0
80107366:	6a 00                	push   $0x0
  pushl $174
80107368:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
8010736d:	e9 12 f3 ff ff       	jmp    80106684 <alltraps>

80107372 <vector175>:
.globl vector175
vector175:
  pushl $0
80107372:	6a 00                	push   $0x0
  pushl $175
80107374:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107379:	e9 06 f3 ff ff       	jmp    80106684 <alltraps>

8010737e <vector176>:
.globl vector176
vector176:
  pushl $0
8010737e:	6a 00                	push   $0x0
  pushl $176
80107380:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107385:	e9 fa f2 ff ff       	jmp    80106684 <alltraps>

8010738a <vector177>:
.globl vector177
vector177:
  pushl $0
8010738a:	6a 00                	push   $0x0
  pushl $177
8010738c:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107391:	e9 ee f2 ff ff       	jmp    80106684 <alltraps>

80107396 <vector178>:
.globl vector178
vector178:
  pushl $0
80107396:	6a 00                	push   $0x0
  pushl $178
80107398:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
8010739d:	e9 e2 f2 ff ff       	jmp    80106684 <alltraps>

801073a2 <vector179>:
.globl vector179
vector179:
  pushl $0
801073a2:	6a 00                	push   $0x0
  pushl $179
801073a4:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801073a9:	e9 d6 f2 ff ff       	jmp    80106684 <alltraps>

801073ae <vector180>:
.globl vector180
vector180:
  pushl $0
801073ae:	6a 00                	push   $0x0
  pushl $180
801073b0:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801073b5:	e9 ca f2 ff ff       	jmp    80106684 <alltraps>

801073ba <vector181>:
.globl vector181
vector181:
  pushl $0
801073ba:	6a 00                	push   $0x0
  pushl $181
801073bc:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801073c1:	e9 be f2 ff ff       	jmp    80106684 <alltraps>

801073c6 <vector182>:
.globl vector182
vector182:
  pushl $0
801073c6:	6a 00                	push   $0x0
  pushl $182
801073c8:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801073cd:	e9 b2 f2 ff ff       	jmp    80106684 <alltraps>

801073d2 <vector183>:
.globl vector183
vector183:
  pushl $0
801073d2:	6a 00                	push   $0x0
  pushl $183
801073d4:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801073d9:	e9 a6 f2 ff ff       	jmp    80106684 <alltraps>

801073de <vector184>:
.globl vector184
vector184:
  pushl $0
801073de:	6a 00                	push   $0x0
  pushl $184
801073e0:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801073e5:	e9 9a f2 ff ff       	jmp    80106684 <alltraps>

801073ea <vector185>:
.globl vector185
vector185:
  pushl $0
801073ea:	6a 00                	push   $0x0
  pushl $185
801073ec:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801073f1:	e9 8e f2 ff ff       	jmp    80106684 <alltraps>

801073f6 <vector186>:
.globl vector186
vector186:
  pushl $0
801073f6:	6a 00                	push   $0x0
  pushl $186
801073f8:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801073fd:	e9 82 f2 ff ff       	jmp    80106684 <alltraps>

80107402 <vector187>:
.globl vector187
vector187:
  pushl $0
80107402:	6a 00                	push   $0x0
  pushl $187
80107404:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107409:	e9 76 f2 ff ff       	jmp    80106684 <alltraps>

8010740e <vector188>:
.globl vector188
vector188:
  pushl $0
8010740e:	6a 00                	push   $0x0
  pushl $188
80107410:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107415:	e9 6a f2 ff ff       	jmp    80106684 <alltraps>

8010741a <vector189>:
.globl vector189
vector189:
  pushl $0
8010741a:	6a 00                	push   $0x0
  pushl $189
8010741c:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107421:	e9 5e f2 ff ff       	jmp    80106684 <alltraps>

80107426 <vector190>:
.globl vector190
vector190:
  pushl $0
80107426:	6a 00                	push   $0x0
  pushl $190
80107428:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
8010742d:	e9 52 f2 ff ff       	jmp    80106684 <alltraps>

80107432 <vector191>:
.globl vector191
vector191:
  pushl $0
80107432:	6a 00                	push   $0x0
  pushl $191
80107434:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107439:	e9 46 f2 ff ff       	jmp    80106684 <alltraps>

8010743e <vector192>:
.globl vector192
vector192:
  pushl $0
8010743e:	6a 00                	push   $0x0
  pushl $192
80107440:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107445:	e9 3a f2 ff ff       	jmp    80106684 <alltraps>

8010744a <vector193>:
.globl vector193
vector193:
  pushl $0
8010744a:	6a 00                	push   $0x0
  pushl $193
8010744c:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107451:	e9 2e f2 ff ff       	jmp    80106684 <alltraps>

80107456 <vector194>:
.globl vector194
vector194:
  pushl $0
80107456:	6a 00                	push   $0x0
  pushl $194
80107458:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
8010745d:	e9 22 f2 ff ff       	jmp    80106684 <alltraps>

80107462 <vector195>:
.globl vector195
vector195:
  pushl $0
80107462:	6a 00                	push   $0x0
  pushl $195
80107464:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107469:	e9 16 f2 ff ff       	jmp    80106684 <alltraps>

8010746e <vector196>:
.globl vector196
vector196:
  pushl $0
8010746e:	6a 00                	push   $0x0
  pushl $196
80107470:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107475:	e9 0a f2 ff ff       	jmp    80106684 <alltraps>

8010747a <vector197>:
.globl vector197
vector197:
  pushl $0
8010747a:	6a 00                	push   $0x0
  pushl $197
8010747c:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107481:	e9 fe f1 ff ff       	jmp    80106684 <alltraps>

80107486 <vector198>:
.globl vector198
vector198:
  pushl $0
80107486:	6a 00                	push   $0x0
  pushl $198
80107488:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010748d:	e9 f2 f1 ff ff       	jmp    80106684 <alltraps>

80107492 <vector199>:
.globl vector199
vector199:
  pushl $0
80107492:	6a 00                	push   $0x0
  pushl $199
80107494:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107499:	e9 e6 f1 ff ff       	jmp    80106684 <alltraps>

8010749e <vector200>:
.globl vector200
vector200:
  pushl $0
8010749e:	6a 00                	push   $0x0
  pushl $200
801074a0:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801074a5:	e9 da f1 ff ff       	jmp    80106684 <alltraps>

801074aa <vector201>:
.globl vector201
vector201:
  pushl $0
801074aa:	6a 00                	push   $0x0
  pushl $201
801074ac:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801074b1:	e9 ce f1 ff ff       	jmp    80106684 <alltraps>

801074b6 <vector202>:
.globl vector202
vector202:
  pushl $0
801074b6:	6a 00                	push   $0x0
  pushl $202
801074b8:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801074bd:	e9 c2 f1 ff ff       	jmp    80106684 <alltraps>

801074c2 <vector203>:
.globl vector203
vector203:
  pushl $0
801074c2:	6a 00                	push   $0x0
  pushl $203
801074c4:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801074c9:	e9 b6 f1 ff ff       	jmp    80106684 <alltraps>

801074ce <vector204>:
.globl vector204
vector204:
  pushl $0
801074ce:	6a 00                	push   $0x0
  pushl $204
801074d0:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801074d5:	e9 aa f1 ff ff       	jmp    80106684 <alltraps>

801074da <vector205>:
.globl vector205
vector205:
  pushl $0
801074da:	6a 00                	push   $0x0
  pushl $205
801074dc:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801074e1:	e9 9e f1 ff ff       	jmp    80106684 <alltraps>

801074e6 <vector206>:
.globl vector206
vector206:
  pushl $0
801074e6:	6a 00                	push   $0x0
  pushl $206
801074e8:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801074ed:	e9 92 f1 ff ff       	jmp    80106684 <alltraps>

801074f2 <vector207>:
.globl vector207
vector207:
  pushl $0
801074f2:	6a 00                	push   $0x0
  pushl $207
801074f4:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801074f9:	e9 86 f1 ff ff       	jmp    80106684 <alltraps>

801074fe <vector208>:
.globl vector208
vector208:
  pushl $0
801074fe:	6a 00                	push   $0x0
  pushl $208
80107500:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107505:	e9 7a f1 ff ff       	jmp    80106684 <alltraps>

8010750a <vector209>:
.globl vector209
vector209:
  pushl $0
8010750a:	6a 00                	push   $0x0
  pushl $209
8010750c:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107511:	e9 6e f1 ff ff       	jmp    80106684 <alltraps>

80107516 <vector210>:
.globl vector210
vector210:
  pushl $0
80107516:	6a 00                	push   $0x0
  pushl $210
80107518:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
8010751d:	e9 62 f1 ff ff       	jmp    80106684 <alltraps>

80107522 <vector211>:
.globl vector211
vector211:
  pushl $0
80107522:	6a 00                	push   $0x0
  pushl $211
80107524:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107529:	e9 56 f1 ff ff       	jmp    80106684 <alltraps>

8010752e <vector212>:
.globl vector212
vector212:
  pushl $0
8010752e:	6a 00                	push   $0x0
  pushl $212
80107530:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107535:	e9 4a f1 ff ff       	jmp    80106684 <alltraps>

8010753a <vector213>:
.globl vector213
vector213:
  pushl $0
8010753a:	6a 00                	push   $0x0
  pushl $213
8010753c:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107541:	e9 3e f1 ff ff       	jmp    80106684 <alltraps>

80107546 <vector214>:
.globl vector214
vector214:
  pushl $0
80107546:	6a 00                	push   $0x0
  pushl $214
80107548:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
8010754d:	e9 32 f1 ff ff       	jmp    80106684 <alltraps>

80107552 <vector215>:
.globl vector215
vector215:
  pushl $0
80107552:	6a 00                	push   $0x0
  pushl $215
80107554:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107559:	e9 26 f1 ff ff       	jmp    80106684 <alltraps>

8010755e <vector216>:
.globl vector216
vector216:
  pushl $0
8010755e:	6a 00                	push   $0x0
  pushl $216
80107560:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107565:	e9 1a f1 ff ff       	jmp    80106684 <alltraps>

8010756a <vector217>:
.globl vector217
vector217:
  pushl $0
8010756a:	6a 00                	push   $0x0
  pushl $217
8010756c:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107571:	e9 0e f1 ff ff       	jmp    80106684 <alltraps>

80107576 <vector218>:
.globl vector218
vector218:
  pushl $0
80107576:	6a 00                	push   $0x0
  pushl $218
80107578:	68 da 00 00 00       	push   $0xda
  jmp alltraps
8010757d:	e9 02 f1 ff ff       	jmp    80106684 <alltraps>

80107582 <vector219>:
.globl vector219
vector219:
  pushl $0
80107582:	6a 00                	push   $0x0
  pushl $219
80107584:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107589:	e9 f6 f0 ff ff       	jmp    80106684 <alltraps>

8010758e <vector220>:
.globl vector220
vector220:
  pushl $0
8010758e:	6a 00                	push   $0x0
  pushl $220
80107590:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107595:	e9 ea f0 ff ff       	jmp    80106684 <alltraps>

8010759a <vector221>:
.globl vector221
vector221:
  pushl $0
8010759a:	6a 00                	push   $0x0
  pushl $221
8010759c:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801075a1:	e9 de f0 ff ff       	jmp    80106684 <alltraps>

801075a6 <vector222>:
.globl vector222
vector222:
  pushl $0
801075a6:	6a 00                	push   $0x0
  pushl $222
801075a8:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801075ad:	e9 d2 f0 ff ff       	jmp    80106684 <alltraps>

801075b2 <vector223>:
.globl vector223
vector223:
  pushl $0
801075b2:	6a 00                	push   $0x0
  pushl $223
801075b4:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801075b9:	e9 c6 f0 ff ff       	jmp    80106684 <alltraps>

801075be <vector224>:
.globl vector224
vector224:
  pushl $0
801075be:	6a 00                	push   $0x0
  pushl $224
801075c0:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801075c5:	e9 ba f0 ff ff       	jmp    80106684 <alltraps>

801075ca <vector225>:
.globl vector225
vector225:
  pushl $0
801075ca:	6a 00                	push   $0x0
  pushl $225
801075cc:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801075d1:	e9 ae f0 ff ff       	jmp    80106684 <alltraps>

801075d6 <vector226>:
.globl vector226
vector226:
  pushl $0
801075d6:	6a 00                	push   $0x0
  pushl $226
801075d8:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801075dd:	e9 a2 f0 ff ff       	jmp    80106684 <alltraps>

801075e2 <vector227>:
.globl vector227
vector227:
  pushl $0
801075e2:	6a 00                	push   $0x0
  pushl $227
801075e4:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801075e9:	e9 96 f0 ff ff       	jmp    80106684 <alltraps>

801075ee <vector228>:
.globl vector228
vector228:
  pushl $0
801075ee:	6a 00                	push   $0x0
  pushl $228
801075f0:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801075f5:	e9 8a f0 ff ff       	jmp    80106684 <alltraps>

801075fa <vector229>:
.globl vector229
vector229:
  pushl $0
801075fa:	6a 00                	push   $0x0
  pushl $229
801075fc:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107601:	e9 7e f0 ff ff       	jmp    80106684 <alltraps>

80107606 <vector230>:
.globl vector230
vector230:
  pushl $0
80107606:	6a 00                	push   $0x0
  pushl $230
80107608:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
8010760d:	e9 72 f0 ff ff       	jmp    80106684 <alltraps>

80107612 <vector231>:
.globl vector231
vector231:
  pushl $0
80107612:	6a 00                	push   $0x0
  pushl $231
80107614:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107619:	e9 66 f0 ff ff       	jmp    80106684 <alltraps>

8010761e <vector232>:
.globl vector232
vector232:
  pushl $0
8010761e:	6a 00                	push   $0x0
  pushl $232
80107620:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107625:	e9 5a f0 ff ff       	jmp    80106684 <alltraps>

8010762a <vector233>:
.globl vector233
vector233:
  pushl $0
8010762a:	6a 00                	push   $0x0
  pushl $233
8010762c:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107631:	e9 4e f0 ff ff       	jmp    80106684 <alltraps>

80107636 <vector234>:
.globl vector234
vector234:
  pushl $0
80107636:	6a 00                	push   $0x0
  pushl $234
80107638:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
8010763d:	e9 42 f0 ff ff       	jmp    80106684 <alltraps>

80107642 <vector235>:
.globl vector235
vector235:
  pushl $0
80107642:	6a 00                	push   $0x0
  pushl $235
80107644:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107649:	e9 36 f0 ff ff       	jmp    80106684 <alltraps>

8010764e <vector236>:
.globl vector236
vector236:
  pushl $0
8010764e:	6a 00                	push   $0x0
  pushl $236
80107650:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107655:	e9 2a f0 ff ff       	jmp    80106684 <alltraps>

8010765a <vector237>:
.globl vector237
vector237:
  pushl $0
8010765a:	6a 00                	push   $0x0
  pushl $237
8010765c:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107661:	e9 1e f0 ff ff       	jmp    80106684 <alltraps>

80107666 <vector238>:
.globl vector238
vector238:
  pushl $0
80107666:	6a 00                	push   $0x0
  pushl $238
80107668:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
8010766d:	e9 12 f0 ff ff       	jmp    80106684 <alltraps>

80107672 <vector239>:
.globl vector239
vector239:
  pushl $0
80107672:	6a 00                	push   $0x0
  pushl $239
80107674:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107679:	e9 06 f0 ff ff       	jmp    80106684 <alltraps>

8010767e <vector240>:
.globl vector240
vector240:
  pushl $0
8010767e:	6a 00                	push   $0x0
  pushl $240
80107680:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107685:	e9 fa ef ff ff       	jmp    80106684 <alltraps>

8010768a <vector241>:
.globl vector241
vector241:
  pushl $0
8010768a:	6a 00                	push   $0x0
  pushl $241
8010768c:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107691:	e9 ee ef ff ff       	jmp    80106684 <alltraps>

80107696 <vector242>:
.globl vector242
vector242:
  pushl $0
80107696:	6a 00                	push   $0x0
  pushl $242
80107698:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
8010769d:	e9 e2 ef ff ff       	jmp    80106684 <alltraps>

801076a2 <vector243>:
.globl vector243
vector243:
  pushl $0
801076a2:	6a 00                	push   $0x0
  pushl $243
801076a4:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801076a9:	e9 d6 ef ff ff       	jmp    80106684 <alltraps>

801076ae <vector244>:
.globl vector244
vector244:
  pushl $0
801076ae:	6a 00                	push   $0x0
  pushl $244
801076b0:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801076b5:	e9 ca ef ff ff       	jmp    80106684 <alltraps>

801076ba <vector245>:
.globl vector245
vector245:
  pushl $0
801076ba:	6a 00                	push   $0x0
  pushl $245
801076bc:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801076c1:	e9 be ef ff ff       	jmp    80106684 <alltraps>

801076c6 <vector246>:
.globl vector246
vector246:
  pushl $0
801076c6:	6a 00                	push   $0x0
  pushl $246
801076c8:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801076cd:	e9 b2 ef ff ff       	jmp    80106684 <alltraps>

801076d2 <vector247>:
.globl vector247
vector247:
  pushl $0
801076d2:	6a 00                	push   $0x0
  pushl $247
801076d4:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801076d9:	e9 a6 ef ff ff       	jmp    80106684 <alltraps>

801076de <vector248>:
.globl vector248
vector248:
  pushl $0
801076de:	6a 00                	push   $0x0
  pushl $248
801076e0:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801076e5:	e9 9a ef ff ff       	jmp    80106684 <alltraps>

801076ea <vector249>:
.globl vector249
vector249:
  pushl $0
801076ea:	6a 00                	push   $0x0
  pushl $249
801076ec:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801076f1:	e9 8e ef ff ff       	jmp    80106684 <alltraps>

801076f6 <vector250>:
.globl vector250
vector250:
  pushl $0
801076f6:	6a 00                	push   $0x0
  pushl $250
801076f8:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801076fd:	e9 82 ef ff ff       	jmp    80106684 <alltraps>

80107702 <vector251>:
.globl vector251
vector251:
  pushl $0
80107702:	6a 00                	push   $0x0
  pushl $251
80107704:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107709:	e9 76 ef ff ff       	jmp    80106684 <alltraps>

8010770e <vector252>:
.globl vector252
vector252:
  pushl $0
8010770e:	6a 00                	push   $0x0
  pushl $252
80107710:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107715:	e9 6a ef ff ff       	jmp    80106684 <alltraps>

8010771a <vector253>:
.globl vector253
vector253:
  pushl $0
8010771a:	6a 00                	push   $0x0
  pushl $253
8010771c:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107721:	e9 5e ef ff ff       	jmp    80106684 <alltraps>

80107726 <vector254>:
.globl vector254
vector254:
  pushl $0
80107726:	6a 00                	push   $0x0
  pushl $254
80107728:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
8010772d:	e9 52 ef ff ff       	jmp    80106684 <alltraps>

80107732 <vector255>:
.globl vector255
vector255:
  pushl $0
80107732:	6a 00                	push   $0x0
  pushl $255
80107734:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107739:	e9 46 ef ff ff       	jmp    80106684 <alltraps>
	...

80107740 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107740:	55                   	push   %ebp
80107741:	89 e5                	mov    %esp,%ebp
80107743:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107746:	8b 45 0c             	mov    0xc(%ebp),%eax
80107749:	48                   	dec    %eax
8010774a:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010774e:	8b 45 08             	mov    0x8(%ebp),%eax
80107751:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107755:	8b 45 08             	mov    0x8(%ebp),%eax
80107758:	c1 e8 10             	shr    $0x10,%eax
8010775b:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
8010775f:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107762:	0f 01 10             	lgdtl  (%eax)
}
80107765:	c9                   	leave  
80107766:	c3                   	ret    

80107767 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80107767:	55                   	push   %ebp
80107768:	89 e5                	mov    %esp,%ebp
8010776a:	83 ec 04             	sub    $0x4,%esp
8010776d:	8b 45 08             	mov    0x8(%ebp),%eax
80107770:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107774:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107777:	0f 00 d8             	ltr    %ax
}
8010777a:	c9                   	leave  
8010777b:	c3                   	ret    

8010777c <lcr3>:
  return val;
}

static inline void
lcr3(uint val)
{
8010777c:	55                   	push   %ebp
8010777d:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010777f:	8b 45 08             	mov    0x8(%ebp),%eax
80107782:	0f 22 d8             	mov    %eax,%cr3
}
80107785:	5d                   	pop    %ebp
80107786:	c3                   	ret    

80107787 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107787:	55                   	push   %ebp
80107788:	89 e5                	mov    %esp,%ebp
8010778a:	83 ec 28             	sub    $0x28,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
8010778d:	e8 54 c9 ff ff       	call   801040e6 <cpuid>
80107792:	89 c2                	mov    %eax,%edx
80107794:	89 d0                	mov    %edx,%eax
80107796:	c1 e0 02             	shl    $0x2,%eax
80107799:	01 d0                	add    %edx,%eax
8010779b:	01 c0                	add    %eax,%eax
8010779d:	01 d0                	add    %edx,%eax
8010779f:	c1 e0 04             	shl    $0x4,%eax
801077a2:	05 a0 3a 11 80       	add    $0x80113aa0,%eax
801077a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801077aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077ad:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801077b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077b6:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801077bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077bf:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801077c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077c6:	8a 50 7d             	mov    0x7d(%eax),%dl
801077c9:	83 e2 f0             	and    $0xfffffff0,%edx
801077cc:	83 ca 0a             	or     $0xa,%edx
801077cf:	88 50 7d             	mov    %dl,0x7d(%eax)
801077d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077d5:	8a 50 7d             	mov    0x7d(%eax),%dl
801077d8:	83 ca 10             	or     $0x10,%edx
801077db:	88 50 7d             	mov    %dl,0x7d(%eax)
801077de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077e1:	8a 50 7d             	mov    0x7d(%eax),%dl
801077e4:	83 e2 9f             	and    $0xffffff9f,%edx
801077e7:	88 50 7d             	mov    %dl,0x7d(%eax)
801077ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077ed:	8a 50 7d             	mov    0x7d(%eax),%dl
801077f0:	83 ca 80             	or     $0xffffff80,%edx
801077f3:	88 50 7d             	mov    %dl,0x7d(%eax)
801077f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077f9:	8a 50 7e             	mov    0x7e(%eax),%dl
801077fc:	83 ca 0f             	or     $0xf,%edx
801077ff:	88 50 7e             	mov    %dl,0x7e(%eax)
80107802:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107805:	8a 50 7e             	mov    0x7e(%eax),%dl
80107808:	83 e2 ef             	and    $0xffffffef,%edx
8010780b:	88 50 7e             	mov    %dl,0x7e(%eax)
8010780e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107811:	8a 50 7e             	mov    0x7e(%eax),%dl
80107814:	83 e2 df             	and    $0xffffffdf,%edx
80107817:	88 50 7e             	mov    %dl,0x7e(%eax)
8010781a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010781d:	8a 50 7e             	mov    0x7e(%eax),%dl
80107820:	83 ca 40             	or     $0x40,%edx
80107823:	88 50 7e             	mov    %dl,0x7e(%eax)
80107826:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107829:	8a 50 7e             	mov    0x7e(%eax),%dl
8010782c:	83 ca 80             	or     $0xffffff80,%edx
8010782f:	88 50 7e             	mov    %dl,0x7e(%eax)
80107832:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107835:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107839:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010783c:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107843:	ff ff 
80107845:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107848:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
8010784f:	00 00 
80107851:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107854:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
8010785b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010785e:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80107864:	83 e2 f0             	and    $0xfffffff0,%edx
80107867:	83 ca 02             	or     $0x2,%edx
8010786a:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107870:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107873:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80107879:	83 ca 10             	or     $0x10,%edx
8010787c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107882:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107885:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
8010788b:	83 e2 9f             	and    $0xffffff9f,%edx
8010788e:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107894:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107897:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
8010789d:	83 ca 80             	or     $0xffffff80,%edx
801078a0:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801078a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078a9:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
801078af:	83 ca 0f             	or     $0xf,%edx
801078b2:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801078b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078bb:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
801078c1:	83 e2 ef             	and    $0xffffffef,%edx
801078c4:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801078ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078cd:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
801078d3:	83 e2 df             	and    $0xffffffdf,%edx
801078d6:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801078dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078df:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
801078e5:	83 ca 40             	or     $0x40,%edx
801078e8:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801078ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078f1:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
801078f7:	83 ca 80             	or     $0xffffff80,%edx
801078fa:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107900:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107903:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
8010790a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010790d:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107914:	ff ff 
80107916:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107919:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107920:	00 00 
80107922:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107925:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
8010792c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010792f:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80107935:	83 e2 f0             	and    $0xfffffff0,%edx
80107938:	83 ca 0a             	or     $0xa,%edx
8010793b:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107941:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107944:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
8010794a:	83 ca 10             	or     $0x10,%edx
8010794d:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107953:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107956:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
8010795c:	83 ca 60             	or     $0x60,%edx
8010795f:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107965:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107968:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
8010796e:	83 ca 80             	or     $0xffffff80,%edx
80107971:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107977:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010797a:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80107980:	83 ca 0f             	or     $0xf,%edx
80107983:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107989:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010798c:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80107992:	83 e2 ef             	and    $0xffffffef,%edx
80107995:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010799b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010799e:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
801079a4:	83 e2 df             	and    $0xffffffdf,%edx
801079a7:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801079ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079b0:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
801079b6:	83 ca 40             	or     $0x40,%edx
801079b9:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801079bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079c2:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
801079c8:	83 ca 80             	or     $0xffffff80,%edx
801079cb:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801079d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079d4:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801079db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079de:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801079e5:	ff ff 
801079e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ea:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801079f1:	00 00 
801079f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079f6:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801079fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a00:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
80107a06:	83 e2 f0             	and    $0xfffffff0,%edx
80107a09:	83 ca 02             	or     $0x2,%edx
80107a0c:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107a12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a15:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
80107a1b:	83 ca 10             	or     $0x10,%edx
80107a1e:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107a24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a27:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
80107a2d:	83 ca 60             	or     $0x60,%edx
80107a30:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107a36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a39:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
80107a3f:	83 ca 80             	or     $0xffffff80,%edx
80107a42:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107a48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a4b:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80107a51:	83 ca 0f             	or     $0xf,%edx
80107a54:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a5d:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80107a63:	83 e2 ef             	and    $0xffffffef,%edx
80107a66:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a6f:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80107a75:	83 e2 df             	and    $0xffffffdf,%edx
80107a78:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a81:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80107a87:	83 ca 40             	or     $0x40,%edx
80107a8a:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a93:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80107a99:	83 ca 80             	or     $0xffffff80,%edx
80107a9c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107aa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aa5:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107aac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aaf:	83 c0 70             	add    $0x70,%eax
80107ab2:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
80107ab9:	00 
80107aba:	89 04 24             	mov    %eax,(%esp)
80107abd:	e8 7e fc ff ff       	call   80107740 <lgdt>
}
80107ac2:	c9                   	leave  
80107ac3:	c3                   	ret    

80107ac4 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107ac4:	55                   	push   %ebp
80107ac5:	89 e5                	mov    %esp,%ebp
80107ac7:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107aca:	8b 45 0c             	mov    0xc(%ebp),%eax
80107acd:	c1 e8 16             	shr    $0x16,%eax
80107ad0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107ad7:	8b 45 08             	mov    0x8(%ebp),%eax
80107ada:	01 d0                	add    %edx,%eax
80107adc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107adf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ae2:	8b 00                	mov    (%eax),%eax
80107ae4:	83 e0 01             	and    $0x1,%eax
80107ae7:	85 c0                	test   %eax,%eax
80107ae9:	74 14                	je     80107aff <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107aeb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107aee:	8b 00                	mov    (%eax),%eax
80107af0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107af5:	05 00 00 00 80       	add    $0x80000000,%eax
80107afa:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107afd:	eb 48                	jmp    80107b47 <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107aff:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107b03:	74 0e                	je     80107b13 <walkpgdir+0x4f>
80107b05:	e8 e5 b0 ff ff       	call   80102bef <kalloc>
80107b0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107b0d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107b11:	75 07                	jne    80107b1a <walkpgdir+0x56>
      return 0;
80107b13:	b8 00 00 00 00       	mov    $0x0,%eax
80107b18:	eb 44                	jmp    80107b5e <walkpgdir+0x9a>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107b1a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107b21:	00 
80107b22:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107b29:	00 
80107b2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b2d:	89 04 24             	mov    %eax,(%esp)
80107b30:	e8 f9 d4 ff ff       	call   8010502e <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107b35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b38:	05 00 00 00 80       	add    $0x80000000,%eax
80107b3d:	83 c8 07             	or     $0x7,%eax
80107b40:	89 c2                	mov    %eax,%edx
80107b42:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b45:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107b47:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b4a:	c1 e8 0c             	shr    $0xc,%eax
80107b4d:	25 ff 03 00 00       	and    $0x3ff,%eax
80107b52:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107b59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b5c:	01 d0                	add    %edx,%eax
}
80107b5e:	c9                   	leave  
80107b5f:	c3                   	ret    

80107b60 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107b60:	55                   	push   %ebp
80107b61:	89 e5                	mov    %esp,%ebp
80107b63:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107b66:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b69:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b6e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107b71:	8b 55 0c             	mov    0xc(%ebp),%edx
80107b74:	8b 45 10             	mov    0x10(%ebp),%eax
80107b77:	01 d0                	add    %edx,%eax
80107b79:	48                   	dec    %eax
80107b7a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b7f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107b82:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80107b89:	00 
80107b8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b8d:	89 44 24 04          	mov    %eax,0x4(%esp)
80107b91:	8b 45 08             	mov    0x8(%ebp),%eax
80107b94:	89 04 24             	mov    %eax,(%esp)
80107b97:	e8 28 ff ff ff       	call   80107ac4 <walkpgdir>
80107b9c:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107b9f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107ba3:	75 07                	jne    80107bac <mappages+0x4c>
      return -1;
80107ba5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107baa:	eb 48                	jmp    80107bf4 <mappages+0x94>
    if(*pte & PTE_P)
80107bac:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107baf:	8b 00                	mov    (%eax),%eax
80107bb1:	83 e0 01             	and    $0x1,%eax
80107bb4:	85 c0                	test   %eax,%eax
80107bb6:	74 0c                	je     80107bc4 <mappages+0x64>
      panic("remap");
80107bb8:	c7 04 24 dc 8d 10 80 	movl   $0x80108ddc,(%esp)
80107bbf:	e8 90 89 ff ff       	call   80100554 <panic>
    *pte = pa | perm | PTE_P;
80107bc4:	8b 45 18             	mov    0x18(%ebp),%eax
80107bc7:	0b 45 14             	or     0x14(%ebp),%eax
80107bca:	83 c8 01             	or     $0x1,%eax
80107bcd:	89 c2                	mov    %eax,%edx
80107bcf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107bd2:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107bd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bd7:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107bda:	75 08                	jne    80107be4 <mappages+0x84>
      break;
80107bdc:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80107bdd:	b8 00 00 00 00       	mov    $0x0,%eax
80107be2:	eb 10                	jmp    80107bf4 <mappages+0x94>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
80107be4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107beb:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80107bf2:	eb 8e                	jmp    80107b82 <mappages+0x22>
  return 0;
}
80107bf4:	c9                   	leave  
80107bf5:	c3                   	ret    

80107bf6 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107bf6:	55                   	push   %ebp
80107bf7:	89 e5                	mov    %esp,%ebp
80107bf9:	53                   	push   %ebx
80107bfa:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107bfd:	e8 ed af ff ff       	call   80102bef <kalloc>
80107c02:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107c05:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107c09:	75 0a                	jne    80107c15 <setupkvm+0x1f>
    return 0;
80107c0b:	b8 00 00 00 00       	mov    $0x0,%eax
80107c10:	e9 84 00 00 00       	jmp    80107c99 <setupkvm+0xa3>
  memset(pgdir, 0, PGSIZE);
80107c15:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107c1c:	00 
80107c1d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107c24:	00 
80107c25:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c28:	89 04 24             	mov    %eax,(%esp)
80107c2b:	e8 fe d3 ff ff       	call   8010502e <memset>
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107c30:	c7 45 f4 c0 b4 10 80 	movl   $0x8010b4c0,-0xc(%ebp)
80107c37:	eb 54                	jmp    80107c8d <setupkvm+0x97>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107c39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c3c:	8b 48 0c             	mov    0xc(%eax),%ecx
80107c3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c42:	8b 50 04             	mov    0x4(%eax),%edx
80107c45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c48:	8b 58 08             	mov    0x8(%eax),%ebx
80107c4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c4e:	8b 40 04             	mov    0x4(%eax),%eax
80107c51:	29 c3                	sub    %eax,%ebx
80107c53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c56:	8b 00                	mov    (%eax),%eax
80107c58:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80107c5c:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107c60:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107c64:	89 44 24 04          	mov    %eax,0x4(%esp)
80107c68:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c6b:	89 04 24             	mov    %eax,(%esp)
80107c6e:	e8 ed fe ff ff       	call   80107b60 <mappages>
80107c73:	85 c0                	test   %eax,%eax
80107c75:	79 12                	jns    80107c89 <setupkvm+0x93>
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
80107c77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c7a:	89 04 24             	mov    %eax,(%esp)
80107c7d:	e8 1a 05 00 00       	call   8010819c <freevm>
      return 0;
80107c82:	b8 00 00 00 00       	mov    $0x0,%eax
80107c87:	eb 10                	jmp    80107c99 <setupkvm+0xa3>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107c89:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107c8d:	81 7d f4 00 b5 10 80 	cmpl   $0x8010b500,-0xc(%ebp)
80107c94:	72 a3                	jb     80107c39 <setupkvm+0x43>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
      return 0;
    }
  return pgdir;
80107c96:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107c99:	83 c4 34             	add    $0x34,%esp
80107c9c:	5b                   	pop    %ebx
80107c9d:	5d                   	pop    %ebp
80107c9e:	c3                   	ret    

80107c9f <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107c9f:	55                   	push   %ebp
80107ca0:	89 e5                	mov    %esp,%ebp
80107ca2:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107ca5:	e8 4c ff ff ff       	call   80107bf6 <setupkvm>
80107caa:	a3 c4 68 11 80       	mov    %eax,0x801168c4
  switchkvm();
80107caf:	e8 02 00 00 00       	call   80107cb6 <switchkvm>
}
80107cb4:	c9                   	leave  
80107cb5:	c3                   	ret    

80107cb6 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107cb6:	55                   	push   %ebp
80107cb7:	89 e5                	mov    %esp,%ebp
80107cb9:	83 ec 04             	sub    $0x4,%esp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107cbc:	a1 c4 68 11 80       	mov    0x801168c4,%eax
80107cc1:	05 00 00 00 80       	add    $0x80000000,%eax
80107cc6:	89 04 24             	mov    %eax,(%esp)
80107cc9:	e8 ae fa ff ff       	call   8010777c <lcr3>
}
80107cce:	c9                   	leave  
80107ccf:	c3                   	ret    

80107cd0 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107cd0:	55                   	push   %ebp
80107cd1:	89 e5                	mov    %esp,%ebp
80107cd3:	57                   	push   %edi
80107cd4:	56                   	push   %esi
80107cd5:	53                   	push   %ebx
80107cd6:	83 ec 1c             	sub    $0x1c,%esp
  if(p == 0)
80107cd9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107cdd:	75 0c                	jne    80107ceb <switchuvm+0x1b>
    panic("switchuvm: no process");
80107cdf:	c7 04 24 e2 8d 10 80 	movl   $0x80108de2,(%esp)
80107ce6:	e8 69 88 ff ff       	call   80100554 <panic>
  if(p->kstack == 0)
80107ceb:	8b 45 08             	mov    0x8(%ebp),%eax
80107cee:	8b 40 08             	mov    0x8(%eax),%eax
80107cf1:	85 c0                	test   %eax,%eax
80107cf3:	75 0c                	jne    80107d01 <switchuvm+0x31>
    panic("switchuvm: no kstack");
80107cf5:	c7 04 24 f8 8d 10 80 	movl   $0x80108df8,(%esp)
80107cfc:	e8 53 88 ff ff       	call   80100554 <panic>
  if(p->pgdir == 0)
80107d01:	8b 45 08             	mov    0x8(%ebp),%eax
80107d04:	8b 40 04             	mov    0x4(%eax),%eax
80107d07:	85 c0                	test   %eax,%eax
80107d09:	75 0c                	jne    80107d17 <switchuvm+0x47>
    panic("switchuvm: no pgdir");
80107d0b:	c7 04 24 0d 8e 10 80 	movl   $0x80108e0d,(%esp)
80107d12:	e8 3d 88 ff ff       	call   80100554 <panic>

  pushcli();
80107d17:	e8 0e d2 ff ff       	call   80104f2a <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107d1c:	e8 0a c4 ff ff       	call   8010412b <mycpu>
80107d21:	89 c3                	mov    %eax,%ebx
80107d23:	e8 03 c4 ff ff       	call   8010412b <mycpu>
80107d28:	83 c0 08             	add    $0x8,%eax
80107d2b:	89 c6                	mov    %eax,%esi
80107d2d:	e8 f9 c3 ff ff       	call   8010412b <mycpu>
80107d32:	83 c0 08             	add    $0x8,%eax
80107d35:	c1 e8 10             	shr    $0x10,%eax
80107d38:	89 c7                	mov    %eax,%edi
80107d3a:	e8 ec c3 ff ff       	call   8010412b <mycpu>
80107d3f:	83 c0 08             	add    $0x8,%eax
80107d42:	c1 e8 18             	shr    $0x18,%eax
80107d45:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107d4c:	67 00 
80107d4e:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107d55:	89 f9                	mov    %edi,%ecx
80107d57:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80107d5d:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80107d63:	83 e2 f0             	and    $0xfffffff0,%edx
80107d66:	83 ca 09             	or     $0x9,%edx
80107d69:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80107d6f:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80107d75:	83 ca 10             	or     $0x10,%edx
80107d78:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80107d7e:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80107d84:	83 e2 9f             	and    $0xffffff9f,%edx
80107d87:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80107d8d:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80107d93:	83 ca 80             	or     $0xffffff80,%edx
80107d96:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80107d9c:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80107da2:	83 e2 f0             	and    $0xfffffff0,%edx
80107da5:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80107dab:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80107db1:	83 e2 ef             	and    $0xffffffef,%edx
80107db4:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80107dba:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80107dc0:	83 e2 df             	and    $0xffffffdf,%edx
80107dc3:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80107dc9:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80107dcf:	83 ca 40             	or     $0x40,%edx
80107dd2:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80107dd8:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80107dde:	83 e2 7f             	and    $0x7f,%edx
80107de1:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80107de7:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107ded:	e8 39 c3 ff ff       	call   8010412b <mycpu>
80107df2:	8a 90 9d 00 00 00    	mov    0x9d(%eax),%dl
80107df8:	83 e2 ef             	and    $0xffffffef,%edx
80107dfb:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107e01:	e8 25 c3 ff ff       	call   8010412b <mycpu>
80107e06:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107e0c:	e8 1a c3 ff ff       	call   8010412b <mycpu>
80107e11:	8b 55 08             	mov    0x8(%ebp),%edx
80107e14:	8b 52 08             	mov    0x8(%edx),%edx
80107e17:	81 c2 00 10 00 00    	add    $0x1000,%edx
80107e1d:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107e20:	e8 06 c3 ff ff       	call   8010412b <mycpu>
80107e25:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107e2b:	c7 04 24 28 00 00 00 	movl   $0x28,(%esp)
80107e32:	e8 30 f9 ff ff       	call   80107767 <ltr>
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107e37:	8b 45 08             	mov    0x8(%ebp),%eax
80107e3a:	8b 40 04             	mov    0x4(%eax),%eax
80107e3d:	05 00 00 00 80       	add    $0x80000000,%eax
80107e42:	89 04 24             	mov    %eax,(%esp)
80107e45:	e8 32 f9 ff ff       	call   8010777c <lcr3>
  popcli();
80107e4a:	e8 25 d1 ff ff       	call   80104f74 <popcli>
}
80107e4f:	83 c4 1c             	add    $0x1c,%esp
80107e52:	5b                   	pop    %ebx
80107e53:	5e                   	pop    %esi
80107e54:	5f                   	pop    %edi
80107e55:	5d                   	pop    %ebp
80107e56:	c3                   	ret    

80107e57 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107e57:	55                   	push   %ebp
80107e58:	89 e5                	mov    %esp,%ebp
80107e5a:	83 ec 38             	sub    $0x38,%esp
  char *mem;

  if(sz >= PGSIZE)
80107e5d:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107e64:	76 0c                	jbe    80107e72 <inituvm+0x1b>
    panic("inituvm: more than a page");
80107e66:	c7 04 24 21 8e 10 80 	movl   $0x80108e21,(%esp)
80107e6d:	e8 e2 86 ff ff       	call   80100554 <panic>
  mem = kalloc();
80107e72:	e8 78 ad ff ff       	call   80102bef <kalloc>
80107e77:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107e7a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107e81:	00 
80107e82:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107e89:	00 
80107e8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e8d:	89 04 24             	mov    %eax,(%esp)
80107e90:	e8 99 d1 ff ff       	call   8010502e <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107e95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e98:	05 00 00 00 80       	add    $0x80000000,%eax
80107e9d:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80107ea4:	00 
80107ea5:	89 44 24 0c          	mov    %eax,0xc(%esp)
80107ea9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107eb0:	00 
80107eb1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107eb8:	00 
80107eb9:	8b 45 08             	mov    0x8(%ebp),%eax
80107ebc:	89 04 24             	mov    %eax,(%esp)
80107ebf:	e8 9c fc ff ff       	call   80107b60 <mappages>
  memmove(mem, init, sz);
80107ec4:	8b 45 10             	mov    0x10(%ebp),%eax
80107ec7:	89 44 24 08          	mov    %eax,0x8(%esp)
80107ecb:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ece:	89 44 24 04          	mov    %eax,0x4(%esp)
80107ed2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ed5:	89 04 24             	mov    %eax,(%esp)
80107ed8:	e8 1a d2 ff ff       	call   801050f7 <memmove>
}
80107edd:	c9                   	leave  
80107ede:	c3                   	ret    

80107edf <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107edf:	55                   	push   %ebp
80107ee0:	89 e5                	mov    %esp,%ebp
80107ee2:	83 ec 28             	sub    $0x28,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107ee5:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ee8:	25 ff 0f 00 00       	and    $0xfff,%eax
80107eed:	85 c0                	test   %eax,%eax
80107eef:	74 0c                	je     80107efd <loaduvm+0x1e>
    panic("loaduvm: addr must be page aligned");
80107ef1:	c7 04 24 3c 8e 10 80 	movl   $0x80108e3c,(%esp)
80107ef8:	e8 57 86 ff ff       	call   80100554 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107efd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107f04:	e9 a6 00 00 00       	jmp    80107faf <loaduvm+0xd0>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107f09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f0c:	8b 55 0c             	mov    0xc(%ebp),%edx
80107f0f:	01 d0                	add    %edx,%eax
80107f11:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80107f18:	00 
80107f19:	89 44 24 04          	mov    %eax,0x4(%esp)
80107f1d:	8b 45 08             	mov    0x8(%ebp),%eax
80107f20:	89 04 24             	mov    %eax,(%esp)
80107f23:	e8 9c fb ff ff       	call   80107ac4 <walkpgdir>
80107f28:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107f2b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107f2f:	75 0c                	jne    80107f3d <loaduvm+0x5e>
      panic("loaduvm: address should exist");
80107f31:	c7 04 24 5f 8e 10 80 	movl   $0x80108e5f,(%esp)
80107f38:	e8 17 86 ff ff       	call   80100554 <panic>
    pa = PTE_ADDR(*pte);
80107f3d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f40:	8b 00                	mov    (%eax),%eax
80107f42:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f47:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107f4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f4d:	8b 55 18             	mov    0x18(%ebp),%edx
80107f50:	29 c2                	sub    %eax,%edx
80107f52:	89 d0                	mov    %edx,%eax
80107f54:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107f59:	77 0f                	ja     80107f6a <loaduvm+0x8b>
      n = sz - i;
80107f5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f5e:	8b 55 18             	mov    0x18(%ebp),%edx
80107f61:	29 c2                	sub    %eax,%edx
80107f63:	89 d0                	mov    %edx,%eax
80107f65:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107f68:	eb 07                	jmp    80107f71 <loaduvm+0x92>
    else
      n = PGSIZE;
80107f6a:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107f71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f74:	8b 55 14             	mov    0x14(%ebp),%edx
80107f77:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80107f7a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107f7d:	05 00 00 00 80       	add    $0x80000000,%eax
80107f82:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107f85:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107f89:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80107f8d:	89 44 24 04          	mov    %eax,0x4(%esp)
80107f91:	8b 45 10             	mov    0x10(%ebp),%eax
80107f94:	89 04 24             	mov    %eax,(%esp)
80107f97:	e8 b9 9e ff ff       	call   80101e55 <readi>
80107f9c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107f9f:	74 07                	je     80107fa8 <loaduvm+0xc9>
      return -1;
80107fa1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107fa6:	eb 18                	jmp    80107fc0 <loaduvm+0xe1>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80107fa8:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107faf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fb2:	3b 45 18             	cmp    0x18(%ebp),%eax
80107fb5:	0f 82 4e ff ff ff    	jb     80107f09 <loaduvm+0x2a>
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80107fbb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107fc0:	c9                   	leave  
80107fc1:	c3                   	ret    

80107fc2 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107fc2:	55                   	push   %ebp
80107fc3:	89 e5                	mov    %esp,%ebp
80107fc5:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107fc8:	8b 45 10             	mov    0x10(%ebp),%eax
80107fcb:	85 c0                	test   %eax,%eax
80107fcd:	79 0a                	jns    80107fd9 <allocuvm+0x17>
    return 0;
80107fcf:	b8 00 00 00 00       	mov    $0x0,%eax
80107fd4:	e9 fd 00 00 00       	jmp    801080d6 <allocuvm+0x114>
  if(newsz < oldsz)
80107fd9:	8b 45 10             	mov    0x10(%ebp),%eax
80107fdc:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107fdf:	73 08                	jae    80107fe9 <allocuvm+0x27>
    return oldsz;
80107fe1:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fe4:	e9 ed 00 00 00       	jmp    801080d6 <allocuvm+0x114>

  a = PGROUNDUP(oldsz);
80107fe9:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fec:	05 ff 0f 00 00       	add    $0xfff,%eax
80107ff1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ff6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107ff9:	e9 c9 00 00 00       	jmp    801080c7 <allocuvm+0x105>
    mem = kalloc();
80107ffe:	e8 ec ab ff ff       	call   80102bef <kalloc>
80108003:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108006:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010800a:	75 2f                	jne    8010803b <allocuvm+0x79>
      cprintf("allocuvm out of memory\n");
8010800c:	c7 04 24 7d 8e 10 80 	movl   $0x80108e7d,(%esp)
80108013:	e8 a9 83 ff ff       	call   801003c1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108018:	8b 45 0c             	mov    0xc(%ebp),%eax
8010801b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010801f:	8b 45 10             	mov    0x10(%ebp),%eax
80108022:	89 44 24 04          	mov    %eax,0x4(%esp)
80108026:	8b 45 08             	mov    0x8(%ebp),%eax
80108029:	89 04 24             	mov    %eax,(%esp)
8010802c:	e8 a7 00 00 00       	call   801080d8 <deallocuvm>
      return 0;
80108031:	b8 00 00 00 00       	mov    $0x0,%eax
80108036:	e9 9b 00 00 00       	jmp    801080d6 <allocuvm+0x114>
    }
    memset(mem, 0, PGSIZE);
8010803b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108042:	00 
80108043:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010804a:	00 
8010804b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010804e:	89 04 24             	mov    %eax,(%esp)
80108051:	e8 d8 cf ff ff       	call   8010502e <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80108056:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108059:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
8010805f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108062:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108069:	00 
8010806a:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010806e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108075:	00 
80108076:	89 44 24 04          	mov    %eax,0x4(%esp)
8010807a:	8b 45 08             	mov    0x8(%ebp),%eax
8010807d:	89 04 24             	mov    %eax,(%esp)
80108080:	e8 db fa ff ff       	call   80107b60 <mappages>
80108085:	85 c0                	test   %eax,%eax
80108087:	79 37                	jns    801080c0 <allocuvm+0xfe>
      cprintf("allocuvm out of memory (2)\n");
80108089:	c7 04 24 95 8e 10 80 	movl   $0x80108e95,(%esp)
80108090:	e8 2c 83 ff ff       	call   801003c1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108095:	8b 45 0c             	mov    0xc(%ebp),%eax
80108098:	89 44 24 08          	mov    %eax,0x8(%esp)
8010809c:	8b 45 10             	mov    0x10(%ebp),%eax
8010809f:	89 44 24 04          	mov    %eax,0x4(%esp)
801080a3:	8b 45 08             	mov    0x8(%ebp),%eax
801080a6:	89 04 24             	mov    %eax,(%esp)
801080a9:	e8 2a 00 00 00       	call   801080d8 <deallocuvm>
      kfree(mem);
801080ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080b1:	89 04 24             	mov    %eax,(%esp)
801080b4:	e8 a0 aa ff ff       	call   80102b59 <kfree>
      return 0;
801080b9:	b8 00 00 00 00       	mov    $0x0,%eax
801080be:	eb 16                	jmp    801080d6 <allocuvm+0x114>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
801080c0:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801080c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080ca:	3b 45 10             	cmp    0x10(%ebp),%eax
801080cd:	0f 82 2b ff ff ff    	jb     80107ffe <allocuvm+0x3c>
      deallocuvm(pgdir, newsz, oldsz);
      kfree(mem);
      return 0;
    }
  }
  return newsz;
801080d3:	8b 45 10             	mov    0x10(%ebp),%eax
}
801080d6:	c9                   	leave  
801080d7:	c3                   	ret    

801080d8 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801080d8:	55                   	push   %ebp
801080d9:	89 e5                	mov    %esp,%ebp
801080db:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801080de:	8b 45 10             	mov    0x10(%ebp),%eax
801080e1:	3b 45 0c             	cmp    0xc(%ebp),%eax
801080e4:	72 08                	jb     801080ee <deallocuvm+0x16>
    return oldsz;
801080e6:	8b 45 0c             	mov    0xc(%ebp),%eax
801080e9:	e9 ac 00 00 00       	jmp    8010819a <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
801080ee:	8b 45 10             	mov    0x10(%ebp),%eax
801080f1:	05 ff 0f 00 00       	add    $0xfff,%eax
801080f6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801080fe:	e9 88 00 00 00       	jmp    8010818b <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108103:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108106:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010810d:	00 
8010810e:	89 44 24 04          	mov    %eax,0x4(%esp)
80108112:	8b 45 08             	mov    0x8(%ebp),%eax
80108115:	89 04 24             	mov    %eax,(%esp)
80108118:	e8 a7 f9 ff ff       	call   80107ac4 <walkpgdir>
8010811d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108120:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108124:	75 14                	jne    8010813a <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80108126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108129:	c1 e8 16             	shr    $0x16,%eax
8010812c:	40                   	inc    %eax
8010812d:	c1 e0 16             	shl    $0x16,%eax
80108130:	2d 00 10 00 00       	sub    $0x1000,%eax
80108135:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108138:	eb 4a                	jmp    80108184 <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
8010813a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010813d:	8b 00                	mov    (%eax),%eax
8010813f:	83 e0 01             	and    $0x1,%eax
80108142:	85 c0                	test   %eax,%eax
80108144:	74 3e                	je     80108184 <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80108146:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108149:	8b 00                	mov    (%eax),%eax
8010814b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108150:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108153:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108157:	75 0c                	jne    80108165 <deallocuvm+0x8d>
        panic("kfree");
80108159:	c7 04 24 b1 8e 10 80 	movl   $0x80108eb1,(%esp)
80108160:	e8 ef 83 ff ff       	call   80100554 <panic>
      char *v = P2V(pa);
80108165:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108168:	05 00 00 00 80       	add    $0x80000000,%eax
8010816d:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108170:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108173:	89 04 24             	mov    %eax,(%esp)
80108176:	e8 de a9 ff ff       	call   80102b59 <kfree>
      *pte = 0;
8010817b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010817e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108184:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010818b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010818e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108191:	0f 82 6c ff ff ff    	jb     80108103 <deallocuvm+0x2b>
      char *v = P2V(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108197:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010819a:	c9                   	leave  
8010819b:	c3                   	ret    

8010819c <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010819c:	55                   	push   %ebp
8010819d:	89 e5                	mov    %esp,%ebp
8010819f:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
801081a2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801081a6:	75 0c                	jne    801081b4 <freevm+0x18>
    panic("freevm: no pgdir");
801081a8:	c7 04 24 b7 8e 10 80 	movl   $0x80108eb7,(%esp)
801081af:	e8 a0 83 ff ff       	call   80100554 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801081b4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801081bb:	00 
801081bc:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
801081c3:	80 
801081c4:	8b 45 08             	mov    0x8(%ebp),%eax
801081c7:	89 04 24             	mov    %eax,(%esp)
801081ca:	e8 09 ff ff ff       	call   801080d8 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
801081cf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801081d6:	eb 44                	jmp    8010821c <freevm+0x80>
    if(pgdir[i] & PTE_P){
801081d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081db:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801081e2:	8b 45 08             	mov    0x8(%ebp),%eax
801081e5:	01 d0                	add    %edx,%eax
801081e7:	8b 00                	mov    (%eax),%eax
801081e9:	83 e0 01             	and    $0x1,%eax
801081ec:	85 c0                	test   %eax,%eax
801081ee:	74 29                	je     80108219 <freevm+0x7d>
      char * v = P2V(PTE_ADDR(pgdir[i]));
801081f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081f3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801081fa:	8b 45 08             	mov    0x8(%ebp),%eax
801081fd:	01 d0                	add    %edx,%eax
801081ff:	8b 00                	mov    (%eax),%eax
80108201:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108206:	05 00 00 00 80       	add    $0x80000000,%eax
8010820b:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
8010820e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108211:	89 04 24             	mov    %eax,(%esp)
80108214:	e8 40 a9 ff ff       	call   80102b59 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108219:	ff 45 f4             	incl   -0xc(%ebp)
8010821c:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108223:	76 b3                	jbe    801081d8 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80108225:	8b 45 08             	mov    0x8(%ebp),%eax
80108228:	89 04 24             	mov    %eax,(%esp)
8010822b:	e8 29 a9 ff ff       	call   80102b59 <kfree>
}
80108230:	c9                   	leave  
80108231:	c3                   	ret    

80108232 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108232:	55                   	push   %ebp
80108233:	89 e5                	mov    %esp,%ebp
80108235:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108238:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010823f:	00 
80108240:	8b 45 0c             	mov    0xc(%ebp),%eax
80108243:	89 44 24 04          	mov    %eax,0x4(%esp)
80108247:	8b 45 08             	mov    0x8(%ebp),%eax
8010824a:	89 04 24             	mov    %eax,(%esp)
8010824d:	e8 72 f8 ff ff       	call   80107ac4 <walkpgdir>
80108252:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108255:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108259:	75 0c                	jne    80108267 <clearpteu+0x35>
    panic("clearpteu");
8010825b:	c7 04 24 c8 8e 10 80 	movl   $0x80108ec8,(%esp)
80108262:	e8 ed 82 ff ff       	call   80100554 <panic>
  *pte &= ~PTE_U;
80108267:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010826a:	8b 00                	mov    (%eax),%eax
8010826c:	83 e0 fb             	and    $0xfffffffb,%eax
8010826f:	89 c2                	mov    %eax,%edx
80108271:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108274:	89 10                	mov    %edx,(%eax)
}
80108276:	c9                   	leave  
80108277:	c3                   	ret    

80108278 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108278:	55                   	push   %ebp
80108279:	89 e5                	mov    %esp,%ebp
8010827b:	83 ec 48             	sub    $0x48,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
8010827e:	e8 73 f9 ff ff       	call   80107bf6 <setupkvm>
80108283:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108286:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010828a:	75 0a                	jne    80108296 <copyuvm+0x1e>
    return 0;
8010828c:	b8 00 00 00 00       	mov    $0x0,%eax
80108291:	e9 f8 00 00 00       	jmp    8010838e <copyuvm+0x116>
  for(i = 0; i < sz; i += PGSIZE){
80108296:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010829d:	e9 cb 00 00 00       	jmp    8010836d <copyuvm+0xf5>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801082a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082a5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801082ac:	00 
801082ad:	89 44 24 04          	mov    %eax,0x4(%esp)
801082b1:	8b 45 08             	mov    0x8(%ebp),%eax
801082b4:	89 04 24             	mov    %eax,(%esp)
801082b7:	e8 08 f8 ff ff       	call   80107ac4 <walkpgdir>
801082bc:	89 45 ec             	mov    %eax,-0x14(%ebp)
801082bf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801082c3:	75 0c                	jne    801082d1 <copyuvm+0x59>
      panic("copyuvm: pte should exist");
801082c5:	c7 04 24 d2 8e 10 80 	movl   $0x80108ed2,(%esp)
801082cc:	e8 83 82 ff ff       	call   80100554 <panic>
    if(!(*pte & PTE_P))
801082d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082d4:	8b 00                	mov    (%eax),%eax
801082d6:	83 e0 01             	and    $0x1,%eax
801082d9:	85 c0                	test   %eax,%eax
801082db:	75 0c                	jne    801082e9 <copyuvm+0x71>
      panic("copyuvm: page not present");
801082dd:	c7 04 24 ec 8e 10 80 	movl   $0x80108eec,(%esp)
801082e4:	e8 6b 82 ff ff       	call   80100554 <panic>
    pa = PTE_ADDR(*pte);
801082e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082ec:	8b 00                	mov    (%eax),%eax
801082ee:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801082f3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801082f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082f9:	8b 00                	mov    (%eax),%eax
801082fb:	25 ff 0f 00 00       	and    $0xfff,%eax
80108300:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108303:	e8 e7 a8 ff ff       	call   80102bef <kalloc>
80108308:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010830b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010830f:	75 02                	jne    80108313 <copyuvm+0x9b>
      goto bad;
80108311:	eb 6b                	jmp    8010837e <copyuvm+0x106>
    memmove(mem, (char*)P2V(pa), PGSIZE);
80108313:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108316:	05 00 00 00 80       	add    $0x80000000,%eax
8010831b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108322:	00 
80108323:	89 44 24 04          	mov    %eax,0x4(%esp)
80108327:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010832a:	89 04 24             	mov    %eax,(%esp)
8010832d:	e8 c5 cd ff ff       	call   801050f7 <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80108332:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108335:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108338:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
8010833e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108341:	89 54 24 10          	mov    %edx,0x10(%esp)
80108345:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80108349:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108350:	00 
80108351:	89 44 24 04          	mov    %eax,0x4(%esp)
80108355:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108358:	89 04 24             	mov    %eax,(%esp)
8010835b:	e8 00 f8 ff ff       	call   80107b60 <mappages>
80108360:	85 c0                	test   %eax,%eax
80108362:	79 02                	jns    80108366 <copyuvm+0xee>
      goto bad;
80108364:	eb 18                	jmp    8010837e <copyuvm+0x106>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108366:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010836d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108370:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108373:	0f 82 29 ff ff ff    	jb     801082a2 <copyuvm+0x2a>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
      goto bad;
  }
  return d;
80108379:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010837c:	eb 10                	jmp    8010838e <copyuvm+0x116>

bad:
  freevm(d);
8010837e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108381:	89 04 24             	mov    %eax,(%esp)
80108384:	e8 13 fe ff ff       	call   8010819c <freevm>
  return 0;
80108389:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010838e:	c9                   	leave  
8010838f:	c3                   	ret    

80108390 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108390:	55                   	push   %ebp
80108391:	89 e5                	mov    %esp,%ebp
80108393:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108396:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010839d:	00 
8010839e:	8b 45 0c             	mov    0xc(%ebp),%eax
801083a1:	89 44 24 04          	mov    %eax,0x4(%esp)
801083a5:	8b 45 08             	mov    0x8(%ebp),%eax
801083a8:	89 04 24             	mov    %eax,(%esp)
801083ab:	e8 14 f7 ff ff       	call   80107ac4 <walkpgdir>
801083b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801083b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083b6:	8b 00                	mov    (%eax),%eax
801083b8:	83 e0 01             	and    $0x1,%eax
801083bb:	85 c0                	test   %eax,%eax
801083bd:	75 07                	jne    801083c6 <uva2ka+0x36>
    return 0;
801083bf:	b8 00 00 00 00       	mov    $0x0,%eax
801083c4:	eb 22                	jmp    801083e8 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
801083c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083c9:	8b 00                	mov    (%eax),%eax
801083cb:	83 e0 04             	and    $0x4,%eax
801083ce:	85 c0                	test   %eax,%eax
801083d0:	75 07                	jne    801083d9 <uva2ka+0x49>
    return 0;
801083d2:	b8 00 00 00 00       	mov    $0x0,%eax
801083d7:	eb 0f                	jmp    801083e8 <uva2ka+0x58>
  return (char*)P2V(PTE_ADDR(*pte));
801083d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083dc:	8b 00                	mov    (%eax),%eax
801083de:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083e3:	05 00 00 00 80       	add    $0x80000000,%eax
}
801083e8:	c9                   	leave  
801083e9:	c3                   	ret    

801083ea <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801083ea:	55                   	push   %ebp
801083eb:	89 e5                	mov    %esp,%ebp
801083ed:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801083f0:	8b 45 10             	mov    0x10(%ebp),%eax
801083f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801083f6:	e9 87 00 00 00       	jmp    80108482 <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
801083fb:	8b 45 0c             	mov    0xc(%ebp),%eax
801083fe:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108403:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108406:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108409:	89 44 24 04          	mov    %eax,0x4(%esp)
8010840d:	8b 45 08             	mov    0x8(%ebp),%eax
80108410:	89 04 24             	mov    %eax,(%esp)
80108413:	e8 78 ff ff ff       	call   80108390 <uva2ka>
80108418:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
8010841b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010841f:	75 07                	jne    80108428 <copyout+0x3e>
      return -1;
80108421:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108426:	eb 69                	jmp    80108491 <copyout+0xa7>
    n = PGSIZE - (va - va0);
80108428:	8b 45 0c             	mov    0xc(%ebp),%eax
8010842b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010842e:	29 c2                	sub    %eax,%edx
80108430:	89 d0                	mov    %edx,%eax
80108432:	05 00 10 00 00       	add    $0x1000,%eax
80108437:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010843a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010843d:	3b 45 14             	cmp    0x14(%ebp),%eax
80108440:	76 06                	jbe    80108448 <copyout+0x5e>
      n = len;
80108442:	8b 45 14             	mov    0x14(%ebp),%eax
80108445:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108448:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010844b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010844e:	29 c2                	sub    %eax,%edx
80108450:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108453:	01 c2                	add    %eax,%edx
80108455:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108458:	89 44 24 08          	mov    %eax,0x8(%esp)
8010845c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010845f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108463:	89 14 24             	mov    %edx,(%esp)
80108466:	e8 8c cc ff ff       	call   801050f7 <memmove>
    len -= n;
8010846b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010846e:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108471:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108474:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108477:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010847a:	05 00 10 00 00       	add    $0x1000,%eax
8010847f:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108482:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108486:	0f 85 6f ff ff ff    	jne    801083fb <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
8010848c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108491:	c9                   	leave  
80108492:	c3                   	ret    
	...

80108494 <strcpy>:

#define MAX_CONTAINERS 4

struct container containers[MAX_CONTAINERS];

char* strcpy(char *s, char *t){
80108494:	55                   	push   %ebp
80108495:	89 e5                	mov    %esp,%ebp
80108497:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
8010849a:	8b 45 08             	mov    0x8(%ebp),%eax
8010849d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
801084a0:	90                   	nop
801084a1:	8b 45 08             	mov    0x8(%ebp),%eax
801084a4:	8d 50 01             	lea    0x1(%eax),%edx
801084a7:	89 55 08             	mov    %edx,0x8(%ebp)
801084aa:	8b 55 0c             	mov    0xc(%ebp),%edx
801084ad:	8d 4a 01             	lea    0x1(%edx),%ecx
801084b0:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801084b3:	8a 12                	mov    (%edx),%dl
801084b5:	88 10                	mov    %dl,(%eax)
801084b7:	8a 00                	mov    (%eax),%al
801084b9:	84 c0                	test   %al,%al
801084bb:	75 e4                	jne    801084a1 <strcpy+0xd>
    ;
  return os;
801084bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801084c0:	c9                   	leave  
801084c1:	c3                   	ret    

801084c2 <get_name>:

void get_name(char* name, int vc_num){
801084c2:	55                   	push   %ebp
801084c3:	89 e5                	mov    %esp,%ebp
801084c5:	57                   	push   %edi
801084c6:	56                   	push   %esi
801084c7:	53                   	push   %ebx
801084c8:	83 ec 28             	sub    $0x28,%esp

	struct container x = containers[vc_num];
801084cb:	8b 55 0c             	mov    0xc(%ebp),%edx
801084ce:	89 d0                	mov    %edx,%eax
801084d0:	01 c0                	add    %eax,%eax
801084d2:	01 d0                	add    %edx,%eax
801084d4:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
801084db:	01 c8                	add    %ecx,%eax
801084dd:	01 d0                	add    %edx,%eax
801084df:	05 e0 68 11 80       	add    $0x801168e0,%eax
801084e4:	8d 55 d8             	lea    -0x28(%ebp),%edx
801084e7:	89 c3                	mov    %eax,%ebx
801084e9:	b8 07 00 00 00       	mov    $0x7,%eax
801084ee:	89 d7                	mov    %edx,%edi
801084f0:	89 de                	mov    %ebx,%esi
801084f2:	89 c1                	mov    %eax,%ecx
801084f4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	strcpy(name, x.name);
801084f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084f9:	89 44 24 04          	mov    %eax,0x4(%esp)
801084fd:	8b 45 08             	mov    0x8(%ebp),%eax
80108500:	89 04 24             	mov    %eax,(%esp)
80108503:	e8 8c ff ff ff       	call   80108494 <strcpy>
}
80108508:	83 c4 28             	add    $0x28,%esp
8010850b:	5b                   	pop    %ebx
8010850c:	5e                   	pop    %esi
8010850d:	5f                   	pop    %edi
8010850e:	5d                   	pop    %ebp
8010850f:	c3                   	ret    

80108510 <get_max_proc>:

int get_max_proc(int vc_num){
80108510:	55                   	push   %ebp
80108511:	89 e5                	mov    %esp,%ebp
80108513:	57                   	push   %edi
80108514:	56                   	push   %esi
80108515:	53                   	push   %ebx
80108516:	83 ec 20             	sub    $0x20,%esp
	struct container x = containers[vc_num];
80108519:	8b 55 08             	mov    0x8(%ebp),%edx
8010851c:	89 d0                	mov    %edx,%eax
8010851e:	01 c0                	add    %eax,%eax
80108520:	01 d0                	add    %edx,%eax
80108522:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
80108529:	01 c8                	add    %ecx,%eax
8010852b:	01 d0                	add    %edx,%eax
8010852d:	05 e0 68 11 80       	add    $0x801168e0,%eax
80108532:	8d 55 d8             	lea    -0x28(%ebp),%edx
80108535:	89 c3                	mov    %eax,%ebx
80108537:	b8 07 00 00 00       	mov    $0x7,%eax
8010853c:	89 d7                	mov    %edx,%edi
8010853e:	89 de                	mov    %ebx,%esi
80108540:	89 c1                	mov    %eax,%ecx
80108542:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.max_proc;
80108544:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
80108547:	83 c4 20             	add    $0x20,%esp
8010854a:	5b                   	pop    %ebx
8010854b:	5e                   	pop    %esi
8010854c:	5f                   	pop    %edi
8010854d:	5d                   	pop    %ebp
8010854e:	c3                   	ret    

8010854f <get_max_mem>:

int get_max_mem(int vc_num){
8010854f:	55                   	push   %ebp
80108550:	89 e5                	mov    %esp,%ebp
80108552:	57                   	push   %edi
80108553:	56                   	push   %esi
80108554:	53                   	push   %ebx
80108555:	83 ec 20             	sub    $0x20,%esp
	struct container x = containers[vc_num];
80108558:	8b 55 08             	mov    0x8(%ebp),%edx
8010855b:	89 d0                	mov    %edx,%eax
8010855d:	01 c0                	add    %eax,%eax
8010855f:	01 d0                	add    %edx,%eax
80108561:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
80108568:	01 c8                	add    %ecx,%eax
8010856a:	01 d0                	add    %edx,%eax
8010856c:	05 e0 68 11 80       	add    $0x801168e0,%eax
80108571:	8d 55 d8             	lea    -0x28(%ebp),%edx
80108574:	89 c3                	mov    %eax,%ebx
80108576:	b8 07 00 00 00       	mov    $0x7,%eax
8010857b:	89 d7                	mov    %edx,%edi
8010857d:	89 de                	mov    %ebx,%esi
8010857f:	89 c1                	mov    %eax,%ecx
80108581:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.max_mem; 
80108583:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80108586:	83 c4 20             	add    $0x20,%esp
80108589:	5b                   	pop    %ebx
8010858a:	5e                   	pop    %esi
8010858b:	5f                   	pop    %edi
8010858c:	5d                   	pop    %ebp
8010858d:	c3                   	ret    

8010858e <get_max_disk>:

int get_max_disk(int vc_num){
8010858e:	55                   	push   %ebp
8010858f:	89 e5                	mov    %esp,%ebp
80108591:	57                   	push   %edi
80108592:	56                   	push   %esi
80108593:	53                   	push   %ebx
80108594:	83 ec 20             	sub    $0x20,%esp
	struct container x = containers[vc_num];
80108597:	8b 55 08             	mov    0x8(%ebp),%edx
8010859a:	89 d0                	mov    %edx,%eax
8010859c:	01 c0                	add    %eax,%eax
8010859e:	01 d0                	add    %edx,%eax
801085a0:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
801085a7:	01 c8                	add    %ecx,%eax
801085a9:	01 d0                	add    %edx,%eax
801085ab:	05 e0 68 11 80       	add    $0x801168e0,%eax
801085b0:	8d 55 d8             	lea    -0x28(%ebp),%edx
801085b3:	89 c3                	mov    %eax,%ebx
801085b5:	b8 07 00 00 00       	mov    $0x7,%eax
801085ba:	89 d7                	mov    %edx,%edi
801085bc:	89 de                	mov    %ebx,%esi
801085be:	89 c1                	mov    %eax,%ecx
801085c0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.max_disk;
801085c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
801085c5:	83 c4 20             	add    $0x20,%esp
801085c8:	5b                   	pop    %ebx
801085c9:	5e                   	pop    %esi
801085ca:	5f                   	pop    %edi
801085cb:	5d                   	pop    %ebp
801085cc:	c3                   	ret    

801085cd <get_curr_proc>:

int get_curr_proc(int vc_num){
801085cd:	55                   	push   %ebp
801085ce:	89 e5                	mov    %esp,%ebp
801085d0:	57                   	push   %edi
801085d1:	56                   	push   %esi
801085d2:	53                   	push   %ebx
801085d3:	83 ec 20             	sub    $0x20,%esp
	struct container x = containers[vc_num];
801085d6:	8b 55 08             	mov    0x8(%ebp),%edx
801085d9:	89 d0                	mov    %edx,%eax
801085db:	01 c0                	add    %eax,%eax
801085dd:	01 d0                	add    %edx,%eax
801085df:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
801085e6:	01 c8                	add    %ecx,%eax
801085e8:	01 d0                	add    %edx,%eax
801085ea:	05 e0 68 11 80       	add    $0x801168e0,%eax
801085ef:	8d 55 d8             	lea    -0x28(%ebp),%edx
801085f2:	89 c3                	mov    %eax,%ebx
801085f4:	b8 07 00 00 00       	mov    $0x7,%eax
801085f9:	89 d7                	mov    %edx,%edi
801085fb:	89 de                	mov    %ebx,%esi
801085fd:	89 c1                	mov    %eax,%ecx
801085ff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.curr_proc;
80108601:	8b 45 e8             	mov    -0x18(%ebp),%eax
}
80108604:	83 c4 20             	add    $0x20,%esp
80108607:	5b                   	pop    %ebx
80108608:	5e                   	pop    %esi
80108609:	5f                   	pop    %edi
8010860a:	5d                   	pop    %ebp
8010860b:	c3                   	ret    

8010860c <get_curr_mem>:

int get_curr_mem(int vc_num){
8010860c:	55                   	push   %ebp
8010860d:	89 e5                	mov    %esp,%ebp
8010860f:	57                   	push   %edi
80108610:	56                   	push   %esi
80108611:	53                   	push   %ebx
80108612:	83 ec 20             	sub    $0x20,%esp
	struct container x = containers[vc_num];
80108615:	8b 55 08             	mov    0x8(%ebp),%edx
80108618:	89 d0                	mov    %edx,%eax
8010861a:	01 c0                	add    %eax,%eax
8010861c:	01 d0                	add    %edx,%eax
8010861e:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
80108625:	01 c8                	add    %ecx,%eax
80108627:	01 d0                	add    %edx,%eax
80108629:	05 e0 68 11 80       	add    $0x801168e0,%eax
8010862e:	8d 55 d8             	lea    -0x28(%ebp),%edx
80108631:	89 c3                	mov    %eax,%ebx
80108633:	b8 07 00 00 00       	mov    $0x7,%eax
80108638:	89 d7                	mov    %edx,%edi
8010863a:	89 de                	mov    %ebx,%esi
8010863c:	89 c1                	mov    %eax,%ecx
8010863e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.curr_mem; 
80108640:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
80108643:	83 c4 20             	add    $0x20,%esp
80108646:	5b                   	pop    %ebx
80108647:	5e                   	pop    %esi
80108648:	5f                   	pop    %edi
80108649:	5d                   	pop    %ebp
8010864a:	c3                   	ret    

8010864b <get_curr_disk>:

int get_curr_disk(int vc_num){
8010864b:	55                   	push   %ebp
8010864c:	89 e5                	mov    %esp,%ebp
8010864e:	57                   	push   %edi
8010864f:	56                   	push   %esi
80108650:	53                   	push   %ebx
80108651:	83 ec 20             	sub    $0x20,%esp
	struct container x = containers[vc_num];
80108654:	8b 55 08             	mov    0x8(%ebp),%edx
80108657:	89 d0                	mov    %edx,%eax
80108659:	01 c0                	add    %eax,%eax
8010865b:	01 d0                	add    %edx,%eax
8010865d:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
80108664:	01 c8                	add    %ecx,%eax
80108666:	01 d0                	add    %edx,%eax
80108668:	05 e0 68 11 80       	add    $0x801168e0,%eax
8010866d:	8d 55 d8             	lea    -0x28(%ebp),%edx
80108670:	89 c3                	mov    %eax,%ebx
80108672:	b8 07 00 00 00       	mov    $0x7,%eax
80108677:	89 d7                	mov    %edx,%edi
80108679:	89 de                	mov    %ebx,%esi
8010867b:	89 c1                	mov    %eax,%ecx
8010867d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.curr_disk;	
8010867f:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80108682:	83 c4 20             	add    $0x20,%esp
80108685:	5b                   	pop    %ebx
80108686:	5e                   	pop    %esi
80108687:	5f                   	pop    %edi
80108688:	5d                   	pop    %ebp
80108689:	c3                   	ret    

8010868a <set_name>:

void set_name(char* name, int vc_num){
8010868a:	55                   	push   %ebp
8010868b:	89 e5                	mov    %esp,%ebp
8010868d:	83 ec 08             	sub    $0x8,%esp
	strcpy(containers[vc_num].name, name);
80108690:	8b 55 0c             	mov    0xc(%ebp),%edx
80108693:	89 d0                	mov    %edx,%eax
80108695:	01 c0                	add    %eax,%eax
80108697:	01 d0                	add    %edx,%eax
80108699:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
801086a0:	01 c8                	add    %ecx,%eax
801086a2:	01 d0                	add    %edx,%eax
801086a4:	05 f0 68 11 80       	add    $0x801168f0,%eax
801086a9:	8b 40 08             	mov    0x8(%eax),%eax
801086ac:	8b 55 08             	mov    0x8(%ebp),%edx
801086af:	89 54 24 04          	mov    %edx,0x4(%esp)
801086b3:	89 04 24             	mov    %eax,(%esp)
801086b6:	e8 d9 fd ff ff       	call   80108494 <strcpy>
}
801086bb:	c9                   	leave  
801086bc:	c3                   	ret    

801086bd <set_max_mem>:

void set_max_mem(int mem, int vc_num){
801086bd:	55                   	push   %ebp
801086be:	89 e5                	mov    %esp,%ebp
	containers[vc_num].max_mem = mem;
801086c0:	8b 55 0c             	mov    0xc(%ebp),%edx
801086c3:	89 d0                	mov    %edx,%eax
801086c5:	01 c0                	add    %eax,%eax
801086c7:	01 d0                	add    %edx,%eax
801086c9:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
801086d0:	01 c8                	add    %ecx,%eax
801086d2:	01 d0                	add    %edx,%eax
801086d4:	8d 90 e0 68 11 80    	lea    -0x7fee9720(%eax),%edx
801086da:	8b 45 08             	mov    0x8(%ebp),%eax
801086dd:	89 02                	mov    %eax,(%edx)
}
801086df:	5d                   	pop    %ebp
801086e0:	c3                   	ret    

801086e1 <set_max_disk>:

void set_max_disk(int disk, int vc_num){
801086e1:	55                   	push   %ebp
801086e2:	89 e5                	mov    %esp,%ebp
	containers[vc_num].max_disk = disk;
801086e4:	8b 55 0c             	mov    0xc(%ebp),%edx
801086e7:	89 d0                	mov    %edx,%eax
801086e9:	01 c0                	add    %eax,%eax
801086eb:	01 d0                	add    %edx,%eax
801086ed:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
801086f4:	01 c8                	add    %ecx,%eax
801086f6:	01 d0                	add    %edx,%eax
801086f8:	8d 90 e0 68 11 80    	lea    -0x7fee9720(%eax),%edx
801086fe:	8b 45 08             	mov    0x8(%ebp),%eax
80108701:	89 42 08             	mov    %eax,0x8(%edx)
}
80108704:	5d                   	pop    %ebp
80108705:	c3                   	ret    

80108706 <set_max_proc>:

void set_max_proc(int procs, int vc_num){
80108706:	55                   	push   %ebp
80108707:	89 e5                	mov    %esp,%ebp
	containers[vc_num].max_proc = procs;
80108709:	8b 55 0c             	mov    0xc(%ebp),%edx
8010870c:	89 d0                	mov    %edx,%eax
8010870e:	01 c0                	add    %eax,%eax
80108710:	01 d0                	add    %edx,%eax
80108712:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
80108719:	01 c8                	add    %ecx,%eax
8010871b:	01 d0                	add    %edx,%eax
8010871d:	8d 90 e0 68 11 80    	lea    -0x7fee9720(%eax),%edx
80108723:	8b 45 08             	mov    0x8(%ebp),%eax
80108726:	89 42 04             	mov    %eax,0x4(%edx)
}
80108729:	5d                   	pop    %ebp
8010872a:	c3                   	ret    

8010872b <set_curr_mem>:

void set_curr_mem(int mem, int vc_num){
8010872b:	55                   	push   %ebp
8010872c:	89 e5                	mov    %esp,%ebp
	containers[vc_num].curr_mem = mem;	
8010872e:	8b 55 0c             	mov    0xc(%ebp),%edx
80108731:	89 d0                	mov    %edx,%eax
80108733:	01 c0                	add    %eax,%eax
80108735:	01 d0                	add    %edx,%eax
80108737:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
8010873e:	01 c8                	add    %ecx,%eax
80108740:	01 d0                	add    %edx,%eax
80108742:	8d 90 e0 68 11 80    	lea    -0x7fee9720(%eax),%edx
80108748:	8b 45 08             	mov    0x8(%ebp),%eax
8010874b:	89 42 0c             	mov    %eax,0xc(%edx)
}
8010874e:	5d                   	pop    %ebp
8010874f:	c3                   	ret    

80108750 <set_curr_disk>:

void set_curr_disk(int disk, int vc_num){
80108750:	55                   	push   %ebp
80108751:	89 e5                	mov    %esp,%ebp
	containers[vc_num].curr_disk = disk;
80108753:	8b 55 0c             	mov    0xc(%ebp),%edx
80108756:	89 d0                	mov    %edx,%eax
80108758:	01 c0                	add    %eax,%eax
8010875a:	01 d0                	add    %edx,%eax
8010875c:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
80108763:	01 c8                	add    %ecx,%eax
80108765:	01 d0                	add    %edx,%eax
80108767:	8d 90 f0 68 11 80    	lea    -0x7fee9710(%eax),%edx
8010876d:	8b 45 08             	mov    0x8(%ebp),%eax
80108770:	89 42 04             	mov    %eax,0x4(%edx)
}
80108773:	5d                   	pop    %ebp
80108774:	c3                   	ret    

80108775 <set_curr_proc>:

void set_curr_proc(int procs, int vc_num){
80108775:	55                   	push   %ebp
80108776:	89 e5                	mov    %esp,%ebp
	containers[vc_num].curr_proc = procs;	
80108778:	8b 55 0c             	mov    0xc(%ebp),%edx
8010877b:	89 d0                	mov    %edx,%eax
8010877d:	01 c0                	add    %eax,%eax
8010877f:	01 d0                	add    %edx,%eax
80108781:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
80108788:	01 c8                	add    %ecx,%eax
8010878a:	01 d0                	add    %edx,%eax
8010878c:	8d 90 f0 68 11 80    	lea    -0x7fee9710(%eax),%edx
80108792:	8b 45 08             	mov    0x8(%ebp),%eax
80108795:	89 02                	mov    %eax,(%edx)
}
80108797:	5d                   	pop    %ebp
80108798:	c3                   	ret    
