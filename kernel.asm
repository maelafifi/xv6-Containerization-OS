
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
8010002d:	b8 8a 38 10 80       	mov    $0x8010388a,%eax
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
8010003a:	c7 44 24 04 8c 88 10 	movl   $0x8010888c,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 e0 c8 10 80 	movl   $0x8010c8e0,(%esp)
80100049:	e8 4c 4e 00 00       	call   80104e9a <initlock>

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
80100087:	c7 44 24 04 93 88 10 	movl   $0x80108893,0x4(%esp)
8010008e:	80 
8010008f:	89 04 24             	mov    %eax,(%esp)
80100092:	e8 c5 4c 00 00       	call   80104d5c <initsleeplock>
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
801000c9:	e8 ed 4d 00 00       	call   80104ebb <acquire>

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
80100104:	e8 1c 4e 00 00       	call   80104f25 <release>
      acquiresleep(&b->lock);
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	83 c0 0c             	add    $0xc,%eax
8010010f:	89 04 24             	mov    %eax,(%esp)
80100112:	e8 7f 4c 00 00       	call   80104d96 <acquiresleep>
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
8010017d:	e8 a3 4d 00 00       	call   80104f25 <release>
      acquiresleep(&b->lock);
80100182:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100185:	83 c0 0c             	add    $0xc,%eax
80100188:	89 04 24             	mov    %eax,(%esp)
8010018b:	e8 06 4c 00 00       	call   80104d96 <acquiresleep>
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
801001a7:	c7 04 24 9a 88 10 80 	movl   $0x8010889a,(%esp)
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
801001e2:	e8 da 27 00 00       	call   801029c1 <iderw>
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
801001fb:	e8 33 4c 00 00       	call   80104e33 <holdingsleep>
80100200:	85 c0                	test   %eax,%eax
80100202:	75 0c                	jne    80100210 <bwrite+0x24>
    panic("bwrite");
80100204:	c7 04 24 ab 88 10 80 	movl   $0x801088ab,(%esp)
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
80100225:	e8 97 27 00 00       	call   801029c1 <iderw>
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
8010023b:	e8 f3 4b 00 00       	call   80104e33 <holdingsleep>
80100240:	85 c0                	test   %eax,%eax
80100242:	75 0c                	jne    80100250 <brelse+0x24>
    panic("brelse");
80100244:	c7 04 24 b2 88 10 80 	movl   $0x801088b2,(%esp)
8010024b:	e8 04 03 00 00       	call   80100554 <panic>

  releasesleep(&b->lock);
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	83 c0 0c             	add    $0xc,%eax
80100256:	89 04 24             	mov    %eax,(%esp)
80100259:	e8 93 4b 00 00       	call   80104df1 <releasesleep>

  acquire(&bcache.lock);
8010025e:	c7 04 24 e0 c8 10 80 	movl   $0x8010c8e0,(%esp)
80100265:	e8 51 4c 00 00       	call   80104ebb <acquire>
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
801002d1:	e8 4f 4c 00 00       	call   80104f25 <release>
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
801003dc:	e8 da 4a 00 00       	call   80104ebb <acquire>

  if (fmt == 0)
801003e1:	8b 45 08             	mov    0x8(%ebp),%eax
801003e4:	85 c0                	test   %eax,%eax
801003e6:	75 0c                	jne    801003f4 <cprintf+0x33>
    panic("null fmt");
801003e8:	c7 04 24 b9 88 10 80 	movl   $0x801088b9,(%esp)
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
801004cf:	c7 45 ec c2 88 10 80 	movl   $0x801088c2,-0x14(%ebp)
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
8010054d:	e8 d3 49 00 00       	call   80104f25 <release>
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
80100569:	e8 ef 2a 00 00       	call   8010305d <lapicid>
8010056e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100572:	c7 04 24 c9 88 10 80 	movl   $0x801088c9,(%esp)
80100579:	e8 43 fe ff ff       	call   801003c1 <cprintf>
  cprintf(s);
8010057e:	8b 45 08             	mov    0x8(%ebp),%eax
80100581:	89 04 24             	mov    %eax,(%esp)
80100584:	e8 38 fe ff ff       	call   801003c1 <cprintf>
  cprintf("\n");
80100589:	c7 04 24 dd 88 10 80 	movl   $0x801088dd,(%esp)
80100590:	e8 2c fe ff ff       	call   801003c1 <cprintf>
  getcallerpcs(&s, pcs);
80100595:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100598:	89 44 24 04          	mov    %eax,0x4(%esp)
8010059c:	8d 45 08             	lea    0x8(%ebp),%eax
8010059f:	89 04 24             	mov    %eax,(%esp)
801005a2:	e8 cb 49 00 00       	call   80104f72 <getcallerpcs>
  for(i=0; i<10; i++)
801005a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005ae:	eb 1a                	jmp    801005ca <panic+0x76>
    cprintf(" %p", pcs[i]);
801005b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005b3:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005b7:	89 44 24 04          	mov    %eax,0x4(%esp)
801005bb:	c7 04 24 df 88 10 80 	movl   $0x801088df,(%esp)
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
80100695:	c7 04 24 e3 88 10 80 	movl   $0x801088e3,(%esp)
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
801006c9:	e8 19 4b 00 00       	call   801051e7 <memmove>
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
801006f8:	e8 21 4a 00 00       	call   8010511e <memset>
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
8010078e:	e8 71 65 00 00       	call   80106d04 <uartputc>
80100793:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010079a:	e8 65 65 00 00       	call   80106d04 <uartputc>
8010079f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801007a6:	e8 59 65 00 00       	call   80106d04 <uartputc>
801007ab:	eb 0b                	jmp    801007b8 <consputc+0x50>
  } else
    uartputc(c);
801007ad:	8b 45 08             	mov    0x8(%ebp),%eax
801007b0:	89 04 24             	mov    %eax,(%esp)
801007b3:	e8 4c 65 00 00       	call   80106d04 <uartputc>
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
801007f8:	57                   	push   %edi
801007f9:	56                   	push   %esi
801007fa:	53                   	push   %ebx
801007fb:	83 ec 2c             	sub    $0x2c,%esp
  int c, doprocdump = 0, doconsoleswitch = 0;
801007fe:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100805:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)

  acquire(&cons.lock);
8010080c:	c7 04 24 40 b8 10 80 	movl   $0x8010b840,(%esp)
80100813:	e8 a3 46 00 00       	call   80104ebb <acquire>
  while((c = getc()) >= 0){
80100818:	e9 56 02 00 00       	jmp    80100a73 <consoleintr+0x27e>
    switch(c){
8010081d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100820:	83 f8 14             	cmp    $0x14,%eax
80100823:	74 3b                	je     80100860 <consoleintr+0x6b>
80100825:	83 f8 14             	cmp    $0x14,%eax
80100828:	7f 13                	jg     8010083d <consoleintr+0x48>
8010082a:	83 f8 08             	cmp    $0x8,%eax
8010082d:	0f 84 81 01 00 00    	je     801009b4 <consoleintr+0x1bf>
80100833:	83 f8 10             	cmp    $0x10,%eax
80100836:	74 1c                	je     80100854 <consoleintr+0x5f>
80100838:	e9 a7 01 00 00       	jmp    801009e4 <consoleintr+0x1ef>
8010083d:	83 f8 15             	cmp    $0x15,%eax
80100840:	0f 84 46 01 00 00    	je     8010098c <consoleintr+0x197>
80100846:	83 f8 7f             	cmp    $0x7f,%eax
80100849:	0f 84 65 01 00 00    	je     801009b4 <consoleintr+0x1bf>
8010084f:	e9 90 01 00 00       	jmp    801009e4 <consoleintr+0x1ef>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
80100854:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
      break;
8010085b:	e9 13 02 00 00       	jmp    80100a73 <consoleintr+0x27e>
    case C('T'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      if (active == 1){
80100860:	a1 00 90 10 80       	mov    0x80109000,%eax
80100865:	83 f8 01             	cmp    $0x1,%eax
80100868:	75 3d                	jne    801008a7 <consoleintr+0xb2>
        active = 2;
8010086a:	c7 05 00 90 10 80 02 	movl   $0x2,0x80109000
80100871:	00 00 00 
        buf1 = input;
80100874:	ba c0 b5 10 80       	mov    $0x8010b5c0,%edx
80100879:	bb 40 12 11 80       	mov    $0x80111240,%ebx
8010087e:	b8 23 00 00 00       	mov    $0x23,%eax
80100883:	89 d7                	mov    %edx,%edi
80100885:	89 de                	mov    %ebx,%esi
80100887:	89 c1                	mov    %eax,%ecx
80100889:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
        input = buf2;
8010088b:	ba 40 12 11 80       	mov    $0x80111240,%edx
80100890:	bb 60 b6 10 80       	mov    $0x8010b660,%ebx
80100895:	b8 23 00 00 00       	mov    $0x23,%eax
8010089a:	89 d7                	mov    %edx,%edi
8010089c:	89 de                	mov    %ebx,%esi
8010089e:	89 c1                	mov    %eax,%ecx
801008a0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
801008a2:	e9 c0 00 00 00       	jmp    80100967 <consoleintr+0x172>
      }
      else if(active == 2){
801008a7:	a1 00 90 10 80       	mov    0x80109000,%eax
801008ac:	83 f8 02             	cmp    $0x2,%eax
801008af:	75 3a                	jne    801008eb <consoleintr+0xf6>
        active = 3;
801008b1:	c7 05 00 90 10 80 03 	movl   $0x3,0x80109000
801008b8:	00 00 00 
        buf2 = input;
801008bb:	ba 60 b6 10 80       	mov    $0x8010b660,%edx
801008c0:	bb 40 12 11 80       	mov    $0x80111240,%ebx
801008c5:	b8 23 00 00 00       	mov    $0x23,%eax
801008ca:	89 d7                	mov    %edx,%edi
801008cc:	89 de                	mov    %ebx,%esi
801008ce:	89 c1                	mov    %eax,%ecx
801008d0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
        input = buf3;
801008d2:	ba 40 12 11 80       	mov    $0x80111240,%edx
801008d7:	bb 00 b7 10 80       	mov    $0x8010b700,%ebx
801008dc:	b8 23 00 00 00       	mov    $0x23,%eax
801008e1:	89 d7                	mov    %edx,%edi
801008e3:	89 de                	mov    %ebx,%esi
801008e5:	89 c1                	mov    %eax,%ecx
801008e7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
801008e9:	eb 7c                	jmp    80100967 <consoleintr+0x172>
      }
      else if(active == 3){
801008eb:	a1 00 90 10 80       	mov    0x80109000,%eax
801008f0:	83 f8 03             	cmp    $0x3,%eax
801008f3:	75 3a                	jne    8010092f <consoleintr+0x13a>
        active = 4;
801008f5:	c7 05 00 90 10 80 04 	movl   $0x4,0x80109000
801008fc:	00 00 00 
        buf3 = input;
801008ff:	ba 00 b7 10 80       	mov    $0x8010b700,%edx
80100904:	bb 40 12 11 80       	mov    $0x80111240,%ebx
80100909:	b8 23 00 00 00       	mov    $0x23,%eax
8010090e:	89 d7                	mov    %edx,%edi
80100910:	89 de                	mov    %ebx,%esi
80100912:	89 c1                	mov    %eax,%ecx
80100914:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
        input = buf4;
80100916:	ba 40 12 11 80       	mov    $0x80111240,%edx
8010091b:	bb a0 b7 10 80       	mov    $0x8010b7a0,%ebx
80100920:	b8 23 00 00 00       	mov    $0x23,%eax
80100925:	89 d7                	mov    %edx,%edi
80100927:	89 de                	mov    %ebx,%esi
80100929:	89 c1                	mov    %eax,%ecx
8010092b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
8010092d:	eb 38                	jmp    80100967 <consoleintr+0x172>
      }else{
        active = 1;
8010092f:	c7 05 00 90 10 80 01 	movl   $0x1,0x80109000
80100936:	00 00 00 
        buf4 = input;
80100939:	ba a0 b7 10 80       	mov    $0x8010b7a0,%edx
8010093e:	bb 40 12 11 80       	mov    $0x80111240,%ebx
80100943:	b8 23 00 00 00       	mov    $0x23,%eax
80100948:	89 d7                	mov    %edx,%edi
8010094a:	89 de                	mov    %ebx,%esi
8010094c:	89 c1                	mov    %eax,%ecx
8010094e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
        input = buf1;
80100950:	ba 40 12 11 80       	mov    $0x80111240,%edx
80100955:	bb c0 b5 10 80       	mov    $0x8010b5c0,%ebx
8010095a:	b8 23 00 00 00       	mov    $0x23,%eax
8010095f:	89 d7                	mov    %edx,%edi
80100961:	89 de                	mov    %ebx,%esi
80100963:	89 c1                	mov    %eax,%ecx
80100965:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
      }
      doconsoleswitch = 1;
80100967:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
      break;
8010096e:	e9 00 01 00 00       	jmp    80100a73 <consoleintr+0x27e>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100973:	a1 c8 12 11 80       	mov    0x801112c8,%eax
80100978:	48                   	dec    %eax
80100979:	a3 c8 12 11 80       	mov    %eax,0x801112c8
        consputc(BACKSPACE);
8010097e:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
80100985:	e8 de fd ff ff       	call   80100768 <consputc>
8010098a:	eb 01                	jmp    8010098d <consoleintr+0x198>
        input = buf1;
      }
      doconsoleswitch = 1;
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010098c:	90                   	nop
8010098d:	8b 15 c8 12 11 80    	mov    0x801112c8,%edx
80100993:	a1 c4 12 11 80       	mov    0x801112c4,%eax
80100998:	39 c2                	cmp    %eax,%edx
8010099a:	74 13                	je     801009af <consoleintr+0x1ba>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
8010099c:	a1 c8 12 11 80       	mov    0x801112c8,%eax
801009a1:	48                   	dec    %eax
801009a2:	83 e0 7f             	and    $0x7f,%eax
801009a5:	8a 80 40 12 11 80    	mov    -0x7feeedc0(%eax),%al
        input = buf1;
      }
      doconsoleswitch = 1;
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
801009ab:	3c 0a                	cmp    $0xa,%al
801009ad:	75 c4                	jne    80100973 <consoleintr+0x17e>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
801009af:	e9 bf 00 00 00       	jmp    80100a73 <consoleintr+0x27e>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
801009b4:	8b 15 c8 12 11 80    	mov    0x801112c8,%edx
801009ba:	a1 c4 12 11 80       	mov    0x801112c4,%eax
801009bf:	39 c2                	cmp    %eax,%edx
801009c1:	74 1c                	je     801009df <consoleintr+0x1ea>
        input.e--;
801009c3:	a1 c8 12 11 80       	mov    0x801112c8,%eax
801009c8:	48                   	dec    %eax
801009c9:	a3 c8 12 11 80       	mov    %eax,0x801112c8
        consputc(BACKSPACE);
801009ce:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
801009d5:	e8 8e fd ff ff       	call   80100768 <consputc>
      }
      break;
801009da:	e9 94 00 00 00       	jmp    80100a73 <consoleintr+0x27e>
801009df:	e9 8f 00 00 00       	jmp    80100a73 <consoleintr+0x27e>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801009e4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
801009e8:	0f 84 84 00 00 00    	je     80100a72 <consoleintr+0x27d>
801009ee:	8b 15 c8 12 11 80    	mov    0x801112c8,%edx
801009f4:	a1 c0 12 11 80       	mov    0x801112c0,%eax
801009f9:	29 c2                	sub    %eax,%edx
801009fb:	89 d0                	mov    %edx,%eax
801009fd:	83 f8 7f             	cmp    $0x7f,%eax
80100a00:	77 70                	ja     80100a72 <consoleintr+0x27d>
        c = (c == '\r') ? '\n' : c;
80100a02:	83 7d dc 0d          	cmpl   $0xd,-0x24(%ebp)
80100a06:	74 05                	je     80100a0d <consoleintr+0x218>
80100a08:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100a0b:	eb 05                	jmp    80100a12 <consoleintr+0x21d>
80100a0d:	b8 0a 00 00 00       	mov    $0xa,%eax
80100a12:	89 45 dc             	mov    %eax,-0x24(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
80100a15:	a1 c8 12 11 80       	mov    0x801112c8,%eax
80100a1a:	8d 50 01             	lea    0x1(%eax),%edx
80100a1d:	89 15 c8 12 11 80    	mov    %edx,0x801112c8
80100a23:	83 e0 7f             	and    $0x7f,%eax
80100a26:	89 c2                	mov    %eax,%edx
80100a28:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100a2b:	88 82 40 12 11 80    	mov    %al,-0x7feeedc0(%edx)
        consputc(c);
80100a31:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100a34:	89 04 24             	mov    %eax,(%esp)
80100a37:	e8 2c fd ff ff       	call   80100768 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100a3c:	83 7d dc 0a          	cmpl   $0xa,-0x24(%ebp)
80100a40:	74 18                	je     80100a5a <consoleintr+0x265>
80100a42:	83 7d dc 04          	cmpl   $0x4,-0x24(%ebp)
80100a46:	74 12                	je     80100a5a <consoleintr+0x265>
80100a48:	a1 c8 12 11 80       	mov    0x801112c8,%eax
80100a4d:	8b 15 c0 12 11 80    	mov    0x801112c0,%edx
80100a53:	83 ea 80             	sub    $0xffffff80,%edx
80100a56:	39 d0                	cmp    %edx,%eax
80100a58:	75 18                	jne    80100a72 <consoleintr+0x27d>
          input.w = input.e;
80100a5a:	a1 c8 12 11 80       	mov    0x801112c8,%eax
80100a5f:	a3 c4 12 11 80       	mov    %eax,0x801112c4
          wakeup(&input.r);
80100a64:	c7 04 24 c0 12 11 80 	movl   $0x801112c0,(%esp)
80100a6b:	e8 51 41 00 00       	call   80104bc1 <wakeup>
        }
      }
      break;
80100a70:	eb 00                	jmp    80100a72 <consoleintr+0x27d>
80100a72:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c, doprocdump = 0, doconsoleswitch = 0;

  acquire(&cons.lock);
  while((c = getc()) >= 0){
80100a73:	8b 45 08             	mov    0x8(%ebp),%eax
80100a76:	ff d0                	call   *%eax
80100a78:	89 45 dc             	mov    %eax,-0x24(%ebp)
80100a7b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80100a7f:	0f 89 98 fd ff ff    	jns    8010081d <consoleintr+0x28>
        }
      }
      break;
    }
  }
  release(&cons.lock);
80100a85:	c7 04 24 40 b8 10 80 	movl   $0x8010b840,(%esp)
80100a8c:	e8 94 44 00 00       	call   80104f25 <release>
  if(doprocdump){
80100a91:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100a95:	74 05                	je     80100a9c <consoleintr+0x2a7>
    procdump();  // now call procdump() wo. cons.lock held
80100a97:	e8 c8 41 00 00       	call   80104c64 <procdump>
  }
  if(doconsoleswitch){
80100a9c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100aa0:	74 15                	je     80100ab7 <consoleintr+0x2c2>
    cprintf("\nActive console now: %d\n", active);
80100aa2:	a1 00 90 10 80       	mov    0x80109000,%eax
80100aa7:	89 44 24 04          	mov    %eax,0x4(%esp)
80100aab:	c7 04 24 f6 88 10 80 	movl   $0x801088f6,(%esp)
80100ab2:	e8 0a f9 ff ff       	call   801003c1 <cprintf>
  }
}
80100ab7:	83 c4 2c             	add    $0x2c,%esp
80100aba:	5b                   	pop    %ebx
80100abb:	5e                   	pop    %esi
80100abc:	5f                   	pop    %edi
80100abd:	5d                   	pop    %ebp
80100abe:	c3                   	ret    

80100abf <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100abf:	55                   	push   %ebp
80100ac0:	89 e5                	mov    %esp,%ebp
80100ac2:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c;

  iunlock(ip);
80100ac5:	8b 45 08             	mov    0x8(%ebp),%eax
80100ac8:	89 04 24             	mov    %eax,(%esp)
80100acb:	e8 e8 10 00 00       	call   80101bb8 <iunlock>
  target = n;
80100ad0:	8b 45 10             	mov    0x10(%ebp),%eax
80100ad3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100ad6:	c7 04 24 40 b8 10 80 	movl   $0x8010b840,(%esp)
80100add:	e8 d9 43 00 00       	call   80104ebb <acquire>
  while(n > 0){
80100ae2:	e9 b7 00 00 00       	jmp    80100b9e <consoleread+0xdf>
    while((input.r == input.w) || (active != ip->minor)){
80100ae7:	eb 41                	jmp    80100b2a <consoleread+0x6b>
      if(myproc()->killed){
80100ae9:	e8 b1 37 00 00       	call   8010429f <myproc>
80100aee:	8b 40 24             	mov    0x24(%eax),%eax
80100af1:	85 c0                	test   %eax,%eax
80100af3:	74 21                	je     80100b16 <consoleread+0x57>
        release(&cons.lock);
80100af5:	c7 04 24 40 b8 10 80 	movl   $0x8010b840,(%esp)
80100afc:	e8 24 44 00 00       	call   80104f25 <release>
        ilock(ip);
80100b01:	8b 45 08             	mov    0x8(%ebp),%eax
80100b04:	89 04 24             	mov    %eax,(%esp)
80100b07:	e8 a2 0f 00 00       	call   80101aae <ilock>
        return -1;
80100b0c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100b11:	e9 b3 00 00 00       	jmp    80100bc9 <consoleread+0x10a>
      }
      sleep(&input.r, &cons.lock);
80100b16:	c7 44 24 04 40 b8 10 	movl   $0x8010b840,0x4(%esp)
80100b1d:	80 
80100b1e:	c7 04 24 c0 12 11 80 	movl   $0x801112c0,(%esp)
80100b25:	e8 c3 3f 00 00       	call   80104aed <sleep>

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while((input.r == input.w) || (active != ip->minor)){
80100b2a:	8b 15 c0 12 11 80    	mov    0x801112c0,%edx
80100b30:	a1 c4 12 11 80       	mov    0x801112c4,%eax
80100b35:	39 c2                	cmp    %eax,%edx
80100b37:	74 b0                	je     80100ae9 <consoleread+0x2a>
80100b39:	8b 45 08             	mov    0x8(%ebp),%eax
80100b3c:	8b 40 54             	mov    0x54(%eax),%eax
80100b3f:	0f bf d0             	movswl %ax,%edx
80100b42:	a1 00 90 10 80       	mov    0x80109000,%eax
80100b47:	39 c2                	cmp    %eax,%edx
80100b49:	75 9e                	jne    80100ae9 <consoleread+0x2a>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100b4b:	a1 c0 12 11 80       	mov    0x801112c0,%eax
80100b50:	8d 50 01             	lea    0x1(%eax),%edx
80100b53:	89 15 c0 12 11 80    	mov    %edx,0x801112c0
80100b59:	83 e0 7f             	and    $0x7f,%eax
80100b5c:	8a 80 40 12 11 80    	mov    -0x7feeedc0(%eax),%al
80100b62:	0f be c0             	movsbl %al,%eax
80100b65:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100b68:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100b6c:	75 17                	jne    80100b85 <consoleread+0xc6>
      if(n < target){
80100b6e:	8b 45 10             	mov    0x10(%ebp),%eax
80100b71:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100b74:	73 0d                	jae    80100b83 <consoleread+0xc4>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100b76:	a1 c0 12 11 80       	mov    0x801112c0,%eax
80100b7b:	48                   	dec    %eax
80100b7c:	a3 c0 12 11 80       	mov    %eax,0x801112c0
      }
      break;
80100b81:	eb 25                	jmp    80100ba8 <consoleread+0xe9>
80100b83:	eb 23                	jmp    80100ba8 <consoleread+0xe9>
    }
    *dst++ = c;
80100b85:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b88:	8d 50 01             	lea    0x1(%eax),%edx
80100b8b:	89 55 0c             	mov    %edx,0xc(%ebp)
80100b8e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100b91:	88 10                	mov    %dl,(%eax)
    --n;
80100b93:	ff 4d 10             	decl   0x10(%ebp)
    if(c == '\n')
80100b96:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100b9a:	75 02                	jne    80100b9e <consoleread+0xdf>
      break;
80100b9c:	eb 0a                	jmp    80100ba8 <consoleread+0xe9>
  int c;

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
80100b9e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100ba2:	0f 8f 3f ff ff ff    	jg     80100ae7 <consoleread+0x28>
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
  }
  release(&cons.lock);
80100ba8:	c7 04 24 40 b8 10 80 	movl   $0x8010b840,(%esp)
80100baf:	e8 71 43 00 00       	call   80104f25 <release>
  ilock(ip);
80100bb4:	8b 45 08             	mov    0x8(%ebp),%eax
80100bb7:	89 04 24             	mov    %eax,(%esp)
80100bba:	e8 ef 0e 00 00       	call   80101aae <ilock>

  return target - n;
80100bbf:	8b 45 10             	mov    0x10(%ebp),%eax
80100bc2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100bc5:	29 c2                	sub    %eax,%edx
80100bc7:	89 d0                	mov    %edx,%eax
}
80100bc9:	c9                   	leave  
80100bca:	c3                   	ret    

80100bcb <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100bcb:	55                   	push   %ebp
80100bcc:	89 e5                	mov    %esp,%ebp
80100bce:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (active == ip->minor){
80100bd1:	8b 45 08             	mov    0x8(%ebp),%eax
80100bd4:	8b 40 54             	mov    0x54(%eax),%eax
80100bd7:	0f bf d0             	movswl %ax,%edx
80100bda:	a1 00 90 10 80       	mov    0x80109000,%eax
80100bdf:	39 c2                	cmp    %eax,%edx
80100be1:	75 5a                	jne    80100c3d <consolewrite+0x72>
    iunlock(ip);
80100be3:	8b 45 08             	mov    0x8(%ebp),%eax
80100be6:	89 04 24             	mov    %eax,(%esp)
80100be9:	e8 ca 0f 00 00       	call   80101bb8 <iunlock>
    acquire(&cons.lock);
80100bee:	c7 04 24 40 b8 10 80 	movl   $0x8010b840,(%esp)
80100bf5:	e8 c1 42 00 00       	call   80104ebb <acquire>
    for(i = 0; i < n; i++)
80100bfa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100c01:	eb 1b                	jmp    80100c1e <consolewrite+0x53>
      consputc(buf[i] & 0xff);
80100c03:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100c06:	8b 45 0c             	mov    0xc(%ebp),%eax
80100c09:	01 d0                	add    %edx,%eax
80100c0b:	8a 00                	mov    (%eax),%al
80100c0d:	0f be c0             	movsbl %al,%eax
80100c10:	0f b6 c0             	movzbl %al,%eax
80100c13:	89 04 24             	mov    %eax,(%esp)
80100c16:	e8 4d fb ff ff       	call   80100768 <consputc>
  int i;

  if (active == ip->minor){
    iunlock(ip);
    acquire(&cons.lock);
    for(i = 0; i < n; i++)
80100c1b:	ff 45 f4             	incl   -0xc(%ebp)
80100c1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100c21:	3b 45 10             	cmp    0x10(%ebp),%eax
80100c24:	7c dd                	jl     80100c03 <consolewrite+0x38>
      consputc(buf[i] & 0xff);
    release(&cons.lock);
80100c26:	c7 04 24 40 b8 10 80 	movl   $0x8010b840,(%esp)
80100c2d:	e8 f3 42 00 00       	call   80104f25 <release>
    ilock(ip);
80100c32:	8b 45 08             	mov    0x8(%ebp),%eax
80100c35:	89 04 24             	mov    %eax,(%esp)
80100c38:	e8 71 0e 00 00       	call   80101aae <ilock>
  }
  return n;
80100c3d:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100c40:	c9                   	leave  
80100c41:	c3                   	ret    

80100c42 <consoleinit>:

void
consoleinit(void)
{
80100c42:	55                   	push   %ebp
80100c43:	89 e5                	mov    %esp,%ebp
80100c45:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100c48:	c7 44 24 04 0f 89 10 	movl   $0x8010890f,0x4(%esp)
80100c4f:	80 
80100c50:	c7 04 24 40 b8 10 80 	movl   $0x8010b840,(%esp)
80100c57:	e8 3e 42 00 00       	call   80104e9a <initlock>

  devsw[CONSOLE].write = consolewrite;
80100c5c:	c7 05 8c 1c 11 80 cb 	movl   $0x80100bcb,0x80111c8c
80100c63:	0b 10 80 
  devsw[CONSOLE].read = consoleread;
80100c66:	c7 05 88 1c 11 80 bf 	movl   $0x80100abf,0x80111c88
80100c6d:	0a 10 80 
  cons.locking = 1;
80100c70:	c7 05 74 b8 10 80 01 	movl   $0x1,0x8010b874
80100c77:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100c7a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100c81:	00 
80100c82:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100c89:	e8 e5 1e 00 00       	call   80102b73 <ioapicenable>
}
80100c8e:	c9                   	leave  
80100c8f:	c3                   	ret    

80100c90 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100c90:	55                   	push   %ebp
80100c91:	89 e5                	mov    %esp,%ebp
80100c93:	81 ec 38 01 00 00    	sub    $0x138,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100c99:	e8 01 36 00 00       	call   8010429f <myproc>
80100c9e:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100ca1:	e8 01 29 00 00       	call   801035a7 <begin_op>

  if((ip = namei(path)) == 0){
80100ca6:	8b 45 08             	mov    0x8(%ebp),%eax
80100ca9:	89 04 24             	mov    %eax,(%esp)
80100cac:	e8 22 19 00 00       	call   801025d3 <namei>
80100cb1:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100cb4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100cb8:	75 1b                	jne    80100cd5 <exec+0x45>
    end_op();
80100cba:	e8 6a 29 00 00       	call   80103629 <end_op>
    cprintf("exec: fail\n");
80100cbf:	c7 04 24 17 89 10 80 	movl   $0x80108917,(%esp)
80100cc6:	e8 f6 f6 ff ff       	call   801003c1 <cprintf>
    return -1;
80100ccb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100cd0:	e9 f6 03 00 00       	jmp    801010cb <exec+0x43b>
  }
  ilock(ip);
80100cd5:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100cd8:	89 04 24             	mov    %eax,(%esp)
80100cdb:	e8 ce 0d 00 00       	call   80101aae <ilock>
  pgdir = 0;
80100ce0:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100ce7:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100cee:	00 
80100cef:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100cf6:	00 
80100cf7:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100cfd:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d01:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100d04:	89 04 24             	mov    %eax,(%esp)
80100d07:	e8 39 12 00 00       	call   80101f45 <readi>
80100d0c:	83 f8 34             	cmp    $0x34,%eax
80100d0f:	74 05                	je     80100d16 <exec+0x86>
    goto bad;
80100d11:	e9 89 03 00 00       	jmp    8010109f <exec+0x40f>
  if(elf.magic != ELF_MAGIC)
80100d16:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100d1c:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100d21:	74 05                	je     80100d28 <exec+0x98>
    goto bad;
80100d23:	e9 77 03 00 00       	jmp    8010109f <exec+0x40f>

  if((pgdir = setupkvm()) == 0)
80100d28:	e8 b9 6f 00 00       	call   80107ce6 <setupkvm>
80100d2d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100d30:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100d34:	75 05                	jne    80100d3b <exec+0xab>
    goto bad;
80100d36:	e9 64 03 00 00       	jmp    8010109f <exec+0x40f>

  // Load program into memory.
  sz = 0;
80100d3b:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d42:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100d49:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100d4f:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d52:	e9 fb 00 00 00       	jmp    80100e52 <exec+0x1c2>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100d57:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d5a:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100d61:	00 
80100d62:	89 44 24 08          	mov    %eax,0x8(%esp)
80100d66:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100d6c:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d70:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100d73:	89 04 24             	mov    %eax,(%esp)
80100d76:	e8 ca 11 00 00       	call   80101f45 <readi>
80100d7b:	83 f8 20             	cmp    $0x20,%eax
80100d7e:	74 05                	je     80100d85 <exec+0xf5>
      goto bad;
80100d80:	e9 1a 03 00 00       	jmp    8010109f <exec+0x40f>
    if(ph.type != ELF_PROG_LOAD)
80100d85:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100d8b:	83 f8 01             	cmp    $0x1,%eax
80100d8e:	74 05                	je     80100d95 <exec+0x105>
      continue;
80100d90:	e9 b1 00 00 00       	jmp    80100e46 <exec+0x1b6>
    if(ph.memsz < ph.filesz)
80100d95:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100d9b:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100da1:	39 c2                	cmp    %eax,%edx
80100da3:	73 05                	jae    80100daa <exec+0x11a>
      goto bad;
80100da5:	e9 f5 02 00 00       	jmp    8010109f <exec+0x40f>
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100daa:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100db0:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100db6:	01 c2                	add    %eax,%edx
80100db8:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100dbe:	39 c2                	cmp    %eax,%edx
80100dc0:	73 05                	jae    80100dc7 <exec+0x137>
      goto bad;
80100dc2:	e9 d8 02 00 00       	jmp    8010109f <exec+0x40f>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100dc7:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100dcd:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100dd3:	01 d0                	add    %edx,%eax
80100dd5:	89 44 24 08          	mov    %eax,0x8(%esp)
80100dd9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100ddc:	89 44 24 04          	mov    %eax,0x4(%esp)
80100de0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100de3:	89 04 24             	mov    %eax,(%esp)
80100de6:	e8 c7 72 00 00       	call   801080b2 <allocuvm>
80100deb:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100dee:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100df2:	75 05                	jne    80100df9 <exec+0x169>
      goto bad;
80100df4:	e9 a6 02 00 00       	jmp    8010109f <exec+0x40f>
    if(ph.vaddr % PGSIZE != 0)
80100df9:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100dff:	25 ff 0f 00 00       	and    $0xfff,%eax
80100e04:	85 c0                	test   %eax,%eax
80100e06:	74 05                	je     80100e0d <exec+0x17d>
      goto bad;
80100e08:	e9 92 02 00 00       	jmp    8010109f <exec+0x40f>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100e0d:	8b 8d f8 fe ff ff    	mov    -0x108(%ebp),%ecx
80100e13:	8b 95 ec fe ff ff    	mov    -0x114(%ebp),%edx
80100e19:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100e1f:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100e23:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100e27:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100e2a:	89 54 24 08          	mov    %edx,0x8(%esp)
80100e2e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e32:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100e35:	89 04 24             	mov    %eax,(%esp)
80100e38:	e8 92 71 00 00       	call   80107fcf <loaduvm>
80100e3d:	85 c0                	test   %eax,%eax
80100e3f:	79 05                	jns    80100e46 <exec+0x1b6>
      goto bad;
80100e41:	e9 59 02 00 00       	jmp    8010109f <exec+0x40f>
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100e46:	ff 45 ec             	incl   -0x14(%ebp)
80100e49:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100e4c:	83 c0 20             	add    $0x20,%eax
80100e4f:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100e52:	8b 85 34 ff ff ff    	mov    -0xcc(%ebp),%eax
80100e58:	0f b7 c0             	movzwl %ax,%eax
80100e5b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100e5e:	0f 8f f3 fe ff ff    	jg     80100d57 <exec+0xc7>
    if(ph.vaddr % PGSIZE != 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100e64:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100e67:	89 04 24             	mov    %eax,(%esp)
80100e6a:	e8 3e 0e 00 00       	call   80101cad <iunlockput>
  end_op();
80100e6f:	e8 b5 27 00 00       	call   80103629 <end_op>
  ip = 0;
80100e74:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100e7b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e7e:	05 ff 0f 00 00       	add    $0xfff,%eax
80100e83:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100e88:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100e8b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e8e:	05 00 20 00 00       	add    $0x2000,%eax
80100e93:	89 44 24 08          	mov    %eax,0x8(%esp)
80100e97:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e9a:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e9e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100ea1:	89 04 24             	mov    %eax,(%esp)
80100ea4:	e8 09 72 00 00       	call   801080b2 <allocuvm>
80100ea9:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100eac:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100eb0:	75 05                	jne    80100eb7 <exec+0x227>
    goto bad;
80100eb2:	e9 e8 01 00 00       	jmp    8010109f <exec+0x40f>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100eb7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100eba:	2d 00 20 00 00       	sub    $0x2000,%eax
80100ebf:	89 44 24 04          	mov    %eax,0x4(%esp)
80100ec3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100ec6:	89 04 24             	mov    %eax,(%esp)
80100ec9:	e8 54 74 00 00       	call   80108322 <clearpteu>
  sp = sz;
80100ece:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100ed1:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100ed4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100edb:	e9 95 00 00 00       	jmp    80100f75 <exec+0x2e5>
    if(argc >= MAXARG)
80100ee0:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100ee4:	76 05                	jbe    80100eeb <exec+0x25b>
      goto bad;
80100ee6:	e9 b4 01 00 00       	jmp    8010109f <exec+0x40f>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100eeb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eee:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ef5:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ef8:	01 d0                	add    %edx,%eax
80100efa:	8b 00                	mov    (%eax),%eax
80100efc:	89 04 24             	mov    %eax,(%esp)
80100eff:	e8 6d 44 00 00       	call   80105371 <strlen>
80100f04:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f07:	29 c2                	sub    %eax,%edx
80100f09:	89 d0                	mov    %edx,%eax
80100f0b:	48                   	dec    %eax
80100f0c:	83 e0 fc             	and    $0xfffffffc,%eax
80100f0f:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100f12:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f15:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f1c:	8b 45 0c             	mov    0xc(%ebp),%eax
80100f1f:	01 d0                	add    %edx,%eax
80100f21:	8b 00                	mov    (%eax),%eax
80100f23:	89 04 24             	mov    %eax,(%esp)
80100f26:	e8 46 44 00 00       	call   80105371 <strlen>
80100f2b:	40                   	inc    %eax
80100f2c:	89 c2                	mov    %eax,%edx
80100f2e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f31:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100f38:	8b 45 0c             	mov    0xc(%ebp),%eax
80100f3b:	01 c8                	add    %ecx,%eax
80100f3d:	8b 00                	mov    (%eax),%eax
80100f3f:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100f43:	89 44 24 08          	mov    %eax,0x8(%esp)
80100f47:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f4a:	89 44 24 04          	mov    %eax,0x4(%esp)
80100f4e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100f51:	89 04 24             	mov    %eax,(%esp)
80100f54:	e8 81 75 00 00       	call   801084da <copyout>
80100f59:	85 c0                	test   %eax,%eax
80100f5b:	79 05                	jns    80100f62 <exec+0x2d2>
      goto bad;
80100f5d:	e9 3d 01 00 00       	jmp    8010109f <exec+0x40f>
    ustack[3+argc] = sp;
80100f62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f65:	8d 50 03             	lea    0x3(%eax),%edx
80100f68:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f6b:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100f72:	ff 45 e4             	incl   -0x1c(%ebp)
80100f75:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f78:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f7f:	8b 45 0c             	mov    0xc(%ebp),%eax
80100f82:	01 d0                	add    %edx,%eax
80100f84:	8b 00                	mov    (%eax),%eax
80100f86:	85 c0                	test   %eax,%eax
80100f88:	0f 85 52 ff ff ff    	jne    80100ee0 <exec+0x250>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100f8e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f91:	83 c0 03             	add    $0x3,%eax
80100f94:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100f9b:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100f9f:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100fa6:	ff ff ff 
  ustack[1] = argc;
80100fa9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100fac:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100fb2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100fb5:	40                   	inc    %eax
80100fb6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100fbd:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100fc0:	29 d0                	sub    %edx,%eax
80100fc2:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100fc8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100fcb:	83 c0 04             	add    $0x4,%eax
80100fce:	c1 e0 02             	shl    $0x2,%eax
80100fd1:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100fd4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100fd7:	83 c0 04             	add    $0x4,%eax
80100fda:	c1 e0 02             	shl    $0x2,%eax
80100fdd:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100fe1:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100fe7:	89 44 24 08          	mov    %eax,0x8(%esp)
80100feb:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100fee:	89 44 24 04          	mov    %eax,0x4(%esp)
80100ff2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100ff5:	89 04 24             	mov    %eax,(%esp)
80100ff8:	e8 dd 74 00 00       	call   801084da <copyout>
80100ffd:	85 c0                	test   %eax,%eax
80100fff:	79 05                	jns    80101006 <exec+0x376>
    goto bad;
80101001:	e9 99 00 00 00       	jmp    8010109f <exec+0x40f>

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80101006:	8b 45 08             	mov    0x8(%ebp),%eax
80101009:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010100c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010100f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80101012:	eb 13                	jmp    80101027 <exec+0x397>
    if(*s == '/')
80101014:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101017:	8a 00                	mov    (%eax),%al
80101019:	3c 2f                	cmp    $0x2f,%al
8010101b:	75 07                	jne    80101024 <exec+0x394>
      last = s+1;
8010101d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101020:	40                   	inc    %eax
80101021:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80101024:	ff 45 f4             	incl   -0xc(%ebp)
80101027:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010102a:	8a 00                	mov    (%eax),%al
8010102c:	84 c0                	test   %al,%al
8010102e:	75 e4                	jne    80101014 <exec+0x384>
    if(*s == '/')
      last = s+1;
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80101030:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101033:	8d 50 6c             	lea    0x6c(%eax),%edx
80101036:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010103d:	00 
8010103e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101041:	89 44 24 04          	mov    %eax,0x4(%esp)
80101045:	89 14 24             	mov    %edx,(%esp)
80101048:	e8 dd 42 00 00       	call   8010532a <safestrcpy>

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
8010104d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101050:	8b 40 04             	mov    0x4(%eax),%eax
80101053:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80101056:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101059:	8b 55 d4             	mov    -0x2c(%ebp),%edx
8010105c:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
8010105f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101062:	8b 55 e0             	mov    -0x20(%ebp),%edx
80101065:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80101067:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010106a:	8b 40 18             	mov    0x18(%eax),%eax
8010106d:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80101073:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80101076:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101079:	8b 40 18             	mov    0x18(%eax),%eax
8010107c:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010107f:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80101082:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101085:	89 04 24             	mov    %eax,(%esp)
80101088:	e8 33 6d 00 00       	call   80107dc0 <switchuvm>
  freevm(oldpgdir);
8010108d:	8b 45 cc             	mov    -0x34(%ebp),%eax
80101090:	89 04 24             	mov    %eax,(%esp)
80101093:	e8 f4 71 00 00       	call   8010828c <freevm>
  return 0;
80101098:	b8 00 00 00 00       	mov    $0x0,%eax
8010109d:	eb 2c                	jmp    801010cb <exec+0x43b>

 bad:
  if(pgdir)
8010109f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
801010a3:	74 0b                	je     801010b0 <exec+0x420>
    freevm(pgdir);
801010a5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801010a8:	89 04 24             	mov    %eax,(%esp)
801010ab:	e8 dc 71 00 00       	call   8010828c <freevm>
  if(ip){
801010b0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
801010b4:	74 10                	je     801010c6 <exec+0x436>
    iunlockput(ip);
801010b6:	8b 45 d8             	mov    -0x28(%ebp),%eax
801010b9:	89 04 24             	mov    %eax,(%esp)
801010bc:	e8 ec 0b 00 00       	call   80101cad <iunlockput>
    end_op();
801010c1:	e8 63 25 00 00       	call   80103629 <end_op>
  }
  return -1;
801010c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801010cb:	c9                   	leave  
801010cc:	c3                   	ret    
801010cd:	00 00                	add    %al,(%eax)
	...

801010d0 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
801010d0:	55                   	push   %ebp
801010d1:	89 e5                	mov    %esp,%ebp
801010d3:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
801010d6:	c7 44 24 04 23 89 10 	movl   $0x80108923,0x4(%esp)
801010dd:	80 
801010de:	c7 04 24 e0 12 11 80 	movl   $0x801112e0,(%esp)
801010e5:	e8 b0 3d 00 00       	call   80104e9a <initlock>
}
801010ea:	c9                   	leave  
801010eb:	c3                   	ret    

801010ec <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
801010ec:	55                   	push   %ebp
801010ed:	89 e5                	mov    %esp,%ebp
801010ef:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
801010f2:	c7 04 24 e0 12 11 80 	movl   $0x801112e0,(%esp)
801010f9:	e8 bd 3d 00 00       	call   80104ebb <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
801010fe:	c7 45 f4 14 13 11 80 	movl   $0x80111314,-0xc(%ebp)
80101105:	eb 29                	jmp    80101130 <filealloc+0x44>
    if(f->ref == 0){
80101107:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010110a:	8b 40 04             	mov    0x4(%eax),%eax
8010110d:	85 c0                	test   %eax,%eax
8010110f:	75 1b                	jne    8010112c <filealloc+0x40>
      f->ref = 1;
80101111:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101114:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
8010111b:	c7 04 24 e0 12 11 80 	movl   $0x801112e0,(%esp)
80101122:	e8 fe 3d 00 00       	call   80104f25 <release>
      return f;
80101127:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010112a:	eb 1e                	jmp    8010114a <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010112c:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101130:	81 7d f4 74 1c 11 80 	cmpl   $0x80111c74,-0xc(%ebp)
80101137:	72 ce                	jb     80101107 <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80101139:	c7 04 24 e0 12 11 80 	movl   $0x801112e0,(%esp)
80101140:	e8 e0 3d 00 00       	call   80104f25 <release>
  return 0;
80101145:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010114a:	c9                   	leave  
8010114b:	c3                   	ret    

8010114c <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
8010114c:	55                   	push   %ebp
8010114d:	89 e5                	mov    %esp,%ebp
8010114f:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
80101152:	c7 04 24 e0 12 11 80 	movl   $0x801112e0,(%esp)
80101159:	e8 5d 3d 00 00       	call   80104ebb <acquire>
  if(f->ref < 1)
8010115e:	8b 45 08             	mov    0x8(%ebp),%eax
80101161:	8b 40 04             	mov    0x4(%eax),%eax
80101164:	85 c0                	test   %eax,%eax
80101166:	7f 0c                	jg     80101174 <filedup+0x28>
    panic("filedup");
80101168:	c7 04 24 2a 89 10 80 	movl   $0x8010892a,(%esp)
8010116f:	e8 e0 f3 ff ff       	call   80100554 <panic>
  f->ref++;
80101174:	8b 45 08             	mov    0x8(%ebp),%eax
80101177:	8b 40 04             	mov    0x4(%eax),%eax
8010117a:	8d 50 01             	lea    0x1(%eax),%edx
8010117d:	8b 45 08             	mov    0x8(%ebp),%eax
80101180:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101183:	c7 04 24 e0 12 11 80 	movl   $0x801112e0,(%esp)
8010118a:	e8 96 3d 00 00       	call   80104f25 <release>
  return f;
8010118f:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101192:	c9                   	leave  
80101193:	c3                   	ret    

80101194 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101194:	55                   	push   %ebp
80101195:	89 e5                	mov    %esp,%ebp
80101197:	57                   	push   %edi
80101198:	56                   	push   %esi
80101199:	53                   	push   %ebx
8010119a:	83 ec 3c             	sub    $0x3c,%esp
  struct file ff;

  acquire(&ftable.lock);
8010119d:	c7 04 24 e0 12 11 80 	movl   $0x801112e0,(%esp)
801011a4:	e8 12 3d 00 00       	call   80104ebb <acquire>
  if(f->ref < 1)
801011a9:	8b 45 08             	mov    0x8(%ebp),%eax
801011ac:	8b 40 04             	mov    0x4(%eax),%eax
801011af:	85 c0                	test   %eax,%eax
801011b1:	7f 0c                	jg     801011bf <fileclose+0x2b>
    panic("fileclose");
801011b3:	c7 04 24 32 89 10 80 	movl   $0x80108932,(%esp)
801011ba:	e8 95 f3 ff ff       	call   80100554 <panic>
  if(--f->ref > 0){
801011bf:	8b 45 08             	mov    0x8(%ebp),%eax
801011c2:	8b 40 04             	mov    0x4(%eax),%eax
801011c5:	8d 50 ff             	lea    -0x1(%eax),%edx
801011c8:	8b 45 08             	mov    0x8(%ebp),%eax
801011cb:	89 50 04             	mov    %edx,0x4(%eax)
801011ce:	8b 45 08             	mov    0x8(%ebp),%eax
801011d1:	8b 40 04             	mov    0x4(%eax),%eax
801011d4:	85 c0                	test   %eax,%eax
801011d6:	7e 0e                	jle    801011e6 <fileclose+0x52>
    release(&ftable.lock);
801011d8:	c7 04 24 e0 12 11 80 	movl   $0x801112e0,(%esp)
801011df:	e8 41 3d 00 00       	call   80104f25 <release>
801011e4:	eb 70                	jmp    80101256 <fileclose+0xc2>
    return;
  }
  ff = *f;
801011e6:	8b 45 08             	mov    0x8(%ebp),%eax
801011e9:	8d 55 d0             	lea    -0x30(%ebp),%edx
801011ec:	89 c3                	mov    %eax,%ebx
801011ee:	b8 06 00 00 00       	mov    $0x6,%eax
801011f3:	89 d7                	mov    %edx,%edi
801011f5:	89 de                	mov    %ebx,%esi
801011f7:	89 c1                	mov    %eax,%ecx
801011f9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  f->ref = 0;
801011fb:	8b 45 08             	mov    0x8(%ebp),%eax
801011fe:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101205:	8b 45 08             	mov    0x8(%ebp),%eax
80101208:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
8010120e:	c7 04 24 e0 12 11 80 	movl   $0x801112e0,(%esp)
80101215:	e8 0b 3d 00 00       	call   80104f25 <release>

  if(ff.type == FD_PIPE)
8010121a:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010121d:	83 f8 01             	cmp    $0x1,%eax
80101220:	75 17                	jne    80101239 <fileclose+0xa5>
    pipeclose(ff.pipe, ff.writable);
80101222:	8a 45 d9             	mov    -0x27(%ebp),%al
80101225:	0f be d0             	movsbl %al,%edx
80101228:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010122b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010122f:	89 04 24             	mov    %eax,(%esp)
80101232:	e8 00 2d 00 00       	call   80103f37 <pipeclose>
80101237:	eb 1d                	jmp    80101256 <fileclose+0xc2>
  else if(ff.type == FD_INODE){
80101239:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010123c:	83 f8 02             	cmp    $0x2,%eax
8010123f:	75 15                	jne    80101256 <fileclose+0xc2>
    begin_op();
80101241:	e8 61 23 00 00       	call   801035a7 <begin_op>
    iput(ff.ip);
80101246:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101249:	89 04 24             	mov    %eax,(%esp)
8010124c:	e8 ab 09 00 00       	call   80101bfc <iput>
    end_op();
80101251:	e8 d3 23 00 00       	call   80103629 <end_op>
  }
}
80101256:	83 c4 3c             	add    $0x3c,%esp
80101259:	5b                   	pop    %ebx
8010125a:	5e                   	pop    %esi
8010125b:	5f                   	pop    %edi
8010125c:	5d                   	pop    %ebp
8010125d:	c3                   	ret    

8010125e <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
8010125e:	55                   	push   %ebp
8010125f:	89 e5                	mov    %esp,%ebp
80101261:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
80101264:	8b 45 08             	mov    0x8(%ebp),%eax
80101267:	8b 00                	mov    (%eax),%eax
80101269:	83 f8 02             	cmp    $0x2,%eax
8010126c:	75 38                	jne    801012a6 <filestat+0x48>
    ilock(f->ip);
8010126e:	8b 45 08             	mov    0x8(%ebp),%eax
80101271:	8b 40 10             	mov    0x10(%eax),%eax
80101274:	89 04 24             	mov    %eax,(%esp)
80101277:	e8 32 08 00 00       	call   80101aae <ilock>
    stati(f->ip, st);
8010127c:	8b 45 08             	mov    0x8(%ebp),%eax
8010127f:	8b 40 10             	mov    0x10(%eax),%eax
80101282:	8b 55 0c             	mov    0xc(%ebp),%edx
80101285:	89 54 24 04          	mov    %edx,0x4(%esp)
80101289:	89 04 24             	mov    %eax,(%esp)
8010128c:	e8 70 0c 00 00       	call   80101f01 <stati>
    iunlock(f->ip);
80101291:	8b 45 08             	mov    0x8(%ebp),%eax
80101294:	8b 40 10             	mov    0x10(%eax),%eax
80101297:	89 04 24             	mov    %eax,(%esp)
8010129a:	e8 19 09 00 00       	call   80101bb8 <iunlock>
    return 0;
8010129f:	b8 00 00 00 00       	mov    $0x0,%eax
801012a4:	eb 05                	jmp    801012ab <filestat+0x4d>
  }
  return -1;
801012a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801012ab:	c9                   	leave  
801012ac:	c3                   	ret    

801012ad <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801012ad:	55                   	push   %ebp
801012ae:	89 e5                	mov    %esp,%ebp
801012b0:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
801012b3:	8b 45 08             	mov    0x8(%ebp),%eax
801012b6:	8a 40 08             	mov    0x8(%eax),%al
801012b9:	84 c0                	test   %al,%al
801012bb:	75 0a                	jne    801012c7 <fileread+0x1a>
    return -1;
801012bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012c2:	e9 9f 00 00 00       	jmp    80101366 <fileread+0xb9>
  if(f->type == FD_PIPE)
801012c7:	8b 45 08             	mov    0x8(%ebp),%eax
801012ca:	8b 00                	mov    (%eax),%eax
801012cc:	83 f8 01             	cmp    $0x1,%eax
801012cf:	75 1e                	jne    801012ef <fileread+0x42>
    return piperead(f->pipe, addr, n);
801012d1:	8b 45 08             	mov    0x8(%ebp),%eax
801012d4:	8b 40 0c             	mov    0xc(%eax),%eax
801012d7:	8b 55 10             	mov    0x10(%ebp),%edx
801012da:	89 54 24 08          	mov    %edx,0x8(%esp)
801012de:	8b 55 0c             	mov    0xc(%ebp),%edx
801012e1:	89 54 24 04          	mov    %edx,0x4(%esp)
801012e5:	89 04 24             	mov    %eax,(%esp)
801012e8:	e8 c8 2d 00 00       	call   801040b5 <piperead>
801012ed:	eb 77                	jmp    80101366 <fileread+0xb9>
  if(f->type == FD_INODE){
801012ef:	8b 45 08             	mov    0x8(%ebp),%eax
801012f2:	8b 00                	mov    (%eax),%eax
801012f4:	83 f8 02             	cmp    $0x2,%eax
801012f7:	75 61                	jne    8010135a <fileread+0xad>
    ilock(f->ip);
801012f9:	8b 45 08             	mov    0x8(%ebp),%eax
801012fc:	8b 40 10             	mov    0x10(%eax),%eax
801012ff:	89 04 24             	mov    %eax,(%esp)
80101302:	e8 a7 07 00 00       	call   80101aae <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101307:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010130a:	8b 45 08             	mov    0x8(%ebp),%eax
8010130d:	8b 50 14             	mov    0x14(%eax),%edx
80101310:	8b 45 08             	mov    0x8(%ebp),%eax
80101313:	8b 40 10             	mov    0x10(%eax),%eax
80101316:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010131a:	89 54 24 08          	mov    %edx,0x8(%esp)
8010131e:	8b 55 0c             	mov    0xc(%ebp),%edx
80101321:	89 54 24 04          	mov    %edx,0x4(%esp)
80101325:	89 04 24             	mov    %eax,(%esp)
80101328:	e8 18 0c 00 00       	call   80101f45 <readi>
8010132d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101330:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101334:	7e 11                	jle    80101347 <fileread+0x9a>
      f->off += r;
80101336:	8b 45 08             	mov    0x8(%ebp),%eax
80101339:	8b 50 14             	mov    0x14(%eax),%edx
8010133c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010133f:	01 c2                	add    %eax,%edx
80101341:	8b 45 08             	mov    0x8(%ebp),%eax
80101344:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101347:	8b 45 08             	mov    0x8(%ebp),%eax
8010134a:	8b 40 10             	mov    0x10(%eax),%eax
8010134d:	89 04 24             	mov    %eax,(%esp)
80101350:	e8 63 08 00 00       	call   80101bb8 <iunlock>
    return r;
80101355:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101358:	eb 0c                	jmp    80101366 <fileread+0xb9>
  }
  panic("fileread");
8010135a:	c7 04 24 3c 89 10 80 	movl   $0x8010893c,(%esp)
80101361:	e8 ee f1 ff ff       	call   80100554 <panic>
}
80101366:	c9                   	leave  
80101367:	c3                   	ret    

80101368 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101368:	55                   	push   %ebp
80101369:	89 e5                	mov    %esp,%ebp
8010136b:	53                   	push   %ebx
8010136c:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
8010136f:	8b 45 08             	mov    0x8(%ebp),%eax
80101372:	8a 40 09             	mov    0x9(%eax),%al
80101375:	84 c0                	test   %al,%al
80101377:	75 0a                	jne    80101383 <filewrite+0x1b>
    return -1;
80101379:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010137e:	e9 20 01 00 00       	jmp    801014a3 <filewrite+0x13b>
  if(f->type == FD_PIPE)
80101383:	8b 45 08             	mov    0x8(%ebp),%eax
80101386:	8b 00                	mov    (%eax),%eax
80101388:	83 f8 01             	cmp    $0x1,%eax
8010138b:	75 21                	jne    801013ae <filewrite+0x46>
    return pipewrite(f->pipe, addr, n);
8010138d:	8b 45 08             	mov    0x8(%ebp),%eax
80101390:	8b 40 0c             	mov    0xc(%eax),%eax
80101393:	8b 55 10             	mov    0x10(%ebp),%edx
80101396:	89 54 24 08          	mov    %edx,0x8(%esp)
8010139a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010139d:	89 54 24 04          	mov    %edx,0x4(%esp)
801013a1:	89 04 24             	mov    %eax,(%esp)
801013a4:	e8 20 2c 00 00       	call   80103fc9 <pipewrite>
801013a9:	e9 f5 00 00 00       	jmp    801014a3 <filewrite+0x13b>
  if(f->type == FD_INODE){
801013ae:	8b 45 08             	mov    0x8(%ebp),%eax
801013b1:	8b 00                	mov    (%eax),%eax
801013b3:	83 f8 02             	cmp    $0x2,%eax
801013b6:	0f 85 db 00 00 00    	jne    80101497 <filewrite+0x12f>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
801013bc:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
801013c3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801013ca:	e9 a8 00 00 00       	jmp    80101477 <filewrite+0x10f>
      int n1 = n - i;
801013cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013d2:	8b 55 10             	mov    0x10(%ebp),%edx
801013d5:	29 c2                	sub    %eax,%edx
801013d7:	89 d0                	mov    %edx,%eax
801013d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801013dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801013df:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801013e2:	7e 06                	jle    801013ea <filewrite+0x82>
        n1 = max;
801013e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801013e7:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
801013ea:	e8 b8 21 00 00       	call   801035a7 <begin_op>
      ilock(f->ip);
801013ef:	8b 45 08             	mov    0x8(%ebp),%eax
801013f2:	8b 40 10             	mov    0x10(%eax),%eax
801013f5:	89 04 24             	mov    %eax,(%esp)
801013f8:	e8 b1 06 00 00       	call   80101aae <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
801013fd:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101400:	8b 45 08             	mov    0x8(%ebp),%eax
80101403:	8b 50 14             	mov    0x14(%eax),%edx
80101406:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101409:	8b 45 0c             	mov    0xc(%ebp),%eax
8010140c:	01 c3                	add    %eax,%ebx
8010140e:	8b 45 08             	mov    0x8(%ebp),%eax
80101411:	8b 40 10             	mov    0x10(%eax),%eax
80101414:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101418:	89 54 24 08          	mov    %edx,0x8(%esp)
8010141c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80101420:	89 04 24             	mov    %eax,(%esp)
80101423:	e8 81 0c 00 00       	call   801020a9 <writei>
80101428:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010142b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010142f:	7e 11                	jle    80101442 <filewrite+0xda>
        f->off += r;
80101431:	8b 45 08             	mov    0x8(%ebp),%eax
80101434:	8b 50 14             	mov    0x14(%eax),%edx
80101437:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010143a:	01 c2                	add    %eax,%edx
8010143c:	8b 45 08             	mov    0x8(%ebp),%eax
8010143f:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101442:	8b 45 08             	mov    0x8(%ebp),%eax
80101445:	8b 40 10             	mov    0x10(%eax),%eax
80101448:	89 04 24             	mov    %eax,(%esp)
8010144b:	e8 68 07 00 00       	call   80101bb8 <iunlock>
      end_op();
80101450:	e8 d4 21 00 00       	call   80103629 <end_op>

      if(r < 0)
80101455:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101459:	79 02                	jns    8010145d <filewrite+0xf5>
        break;
8010145b:	eb 26                	jmp    80101483 <filewrite+0x11b>
      if(r != n1)
8010145d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101460:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101463:	74 0c                	je     80101471 <filewrite+0x109>
        panic("short filewrite");
80101465:	c7 04 24 45 89 10 80 	movl   $0x80108945,(%esp)
8010146c:	e8 e3 f0 ff ff       	call   80100554 <panic>
      i += r;
80101471:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101474:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
80101477:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010147a:	3b 45 10             	cmp    0x10(%ebp),%eax
8010147d:	0f 8c 4c ff ff ff    	jl     801013cf <filewrite+0x67>
        break;
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
80101483:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101486:	3b 45 10             	cmp    0x10(%ebp),%eax
80101489:	75 05                	jne    80101490 <filewrite+0x128>
8010148b:	8b 45 10             	mov    0x10(%ebp),%eax
8010148e:	eb 05                	jmp    80101495 <filewrite+0x12d>
80101490:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101495:	eb 0c                	jmp    801014a3 <filewrite+0x13b>
  }
  panic("filewrite");
80101497:	c7 04 24 55 89 10 80 	movl   $0x80108955,(%esp)
8010149e:	e8 b1 f0 ff ff       	call   80100554 <panic>
}
801014a3:	83 c4 24             	add    $0x24,%esp
801014a6:	5b                   	pop    %ebx
801014a7:	5d                   	pop    %ebp
801014a8:	c3                   	ret    
801014a9:	00 00                	add    %al,(%eax)
	...

801014ac <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801014ac:	55                   	push   %ebp
801014ad:	89 e5                	mov    %esp,%ebp
801014af:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;

  bp = bread(dev, 1);
801014b2:	8b 45 08             	mov    0x8(%ebp),%eax
801014b5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801014bc:	00 
801014bd:	89 04 24             	mov    %eax,(%esp)
801014c0:	e8 f0 ec ff ff       	call   801001b5 <bread>
801014c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801014c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014cb:	83 c0 5c             	add    $0x5c,%eax
801014ce:	c7 44 24 08 1c 00 00 	movl   $0x1c,0x8(%esp)
801014d5:	00 
801014d6:	89 44 24 04          	mov    %eax,0x4(%esp)
801014da:	8b 45 0c             	mov    0xc(%ebp),%eax
801014dd:	89 04 24             	mov    %eax,(%esp)
801014e0:	e8 02 3d 00 00       	call   801051e7 <memmove>
  brelse(bp);
801014e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014e8:	89 04 24             	mov    %eax,(%esp)
801014eb:	e8 3c ed ff ff       	call   8010022c <brelse>
}
801014f0:	c9                   	leave  
801014f1:	c3                   	ret    

801014f2 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
801014f2:	55                   	push   %ebp
801014f3:	89 e5                	mov    %esp,%ebp
801014f5:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;

  bp = bread(dev, bno);
801014f8:	8b 55 0c             	mov    0xc(%ebp),%edx
801014fb:	8b 45 08             	mov    0x8(%ebp),%eax
801014fe:	89 54 24 04          	mov    %edx,0x4(%esp)
80101502:	89 04 24             	mov    %eax,(%esp)
80101505:	e8 ab ec ff ff       	call   801001b5 <bread>
8010150a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010150d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101510:	83 c0 5c             	add    $0x5c,%eax
80101513:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010151a:	00 
8010151b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101522:	00 
80101523:	89 04 24             	mov    %eax,(%esp)
80101526:	e8 f3 3b 00 00       	call   8010511e <memset>
  log_write(bp);
8010152b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010152e:	89 04 24             	mov    %eax,(%esp)
80101531:	e8 75 22 00 00       	call   801037ab <log_write>
  brelse(bp);
80101536:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101539:	89 04 24             	mov    %eax,(%esp)
8010153c:	e8 eb ec ff ff       	call   8010022c <brelse>
}
80101541:	c9                   	leave  
80101542:	c3                   	ret    

80101543 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101543:	55                   	push   %ebp
80101544:	89 e5                	mov    %esp,%ebp
80101546:	83 ec 28             	sub    $0x28,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
80101549:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101550:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101557:	e9 03 01 00 00       	jmp    8010165f <balloc+0x11c>
    bp = bread(dev, BBLOCK(b, sb));
8010155c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010155f:	85 c0                	test   %eax,%eax
80101561:	79 05                	jns    80101568 <balloc+0x25>
80101563:	05 ff 0f 00 00       	add    $0xfff,%eax
80101568:	c1 f8 0c             	sar    $0xc,%eax
8010156b:	89 c2                	mov    %eax,%edx
8010156d:	a1 f8 1c 11 80       	mov    0x80111cf8,%eax
80101572:	01 d0                	add    %edx,%eax
80101574:	89 44 24 04          	mov    %eax,0x4(%esp)
80101578:	8b 45 08             	mov    0x8(%ebp),%eax
8010157b:	89 04 24             	mov    %eax,(%esp)
8010157e:	e8 32 ec ff ff       	call   801001b5 <bread>
80101583:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101586:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010158d:	e9 9b 00 00 00       	jmp    8010162d <balloc+0xea>
      m = 1 << (bi % 8);
80101592:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101595:	25 07 00 00 80       	and    $0x80000007,%eax
8010159a:	85 c0                	test   %eax,%eax
8010159c:	79 05                	jns    801015a3 <balloc+0x60>
8010159e:	48                   	dec    %eax
8010159f:	83 c8 f8             	or     $0xfffffff8,%eax
801015a2:	40                   	inc    %eax
801015a3:	ba 01 00 00 00       	mov    $0x1,%edx
801015a8:	88 c1                	mov    %al,%cl
801015aa:	d3 e2                	shl    %cl,%edx
801015ac:	89 d0                	mov    %edx,%eax
801015ae:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801015b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015b4:	85 c0                	test   %eax,%eax
801015b6:	79 03                	jns    801015bb <balloc+0x78>
801015b8:	83 c0 07             	add    $0x7,%eax
801015bb:	c1 f8 03             	sar    $0x3,%eax
801015be:	8b 55 ec             	mov    -0x14(%ebp),%edx
801015c1:	8a 44 02 5c          	mov    0x5c(%edx,%eax,1),%al
801015c5:	0f b6 c0             	movzbl %al,%eax
801015c8:	23 45 e8             	and    -0x18(%ebp),%eax
801015cb:	85 c0                	test   %eax,%eax
801015cd:	75 5b                	jne    8010162a <balloc+0xe7>
        bp->data[bi/8] |= m;  // Mark block in use.
801015cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015d2:	85 c0                	test   %eax,%eax
801015d4:	79 03                	jns    801015d9 <balloc+0x96>
801015d6:	83 c0 07             	add    $0x7,%eax
801015d9:	c1 f8 03             	sar    $0x3,%eax
801015dc:	8b 55 ec             	mov    -0x14(%ebp),%edx
801015df:	8a 54 02 5c          	mov    0x5c(%edx,%eax,1),%dl
801015e3:	88 d1                	mov    %dl,%cl
801015e5:	8b 55 e8             	mov    -0x18(%ebp),%edx
801015e8:	09 ca                	or     %ecx,%edx
801015ea:	88 d1                	mov    %dl,%cl
801015ec:	8b 55 ec             	mov    -0x14(%ebp),%edx
801015ef:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
801015f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801015f6:	89 04 24             	mov    %eax,(%esp)
801015f9:	e8 ad 21 00 00       	call   801037ab <log_write>
        brelse(bp);
801015fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101601:	89 04 24             	mov    %eax,(%esp)
80101604:	e8 23 ec ff ff       	call   8010022c <brelse>
        bzero(dev, b + bi);
80101609:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010160c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010160f:	01 c2                	add    %eax,%edx
80101611:	8b 45 08             	mov    0x8(%ebp),%eax
80101614:	89 54 24 04          	mov    %edx,0x4(%esp)
80101618:	89 04 24             	mov    %eax,(%esp)
8010161b:	e8 d2 fe ff ff       	call   801014f2 <bzero>
        return b + bi;
80101620:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101623:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101626:	01 d0                	add    %edx,%eax
80101628:	eb 51                	jmp    8010167b <balloc+0x138>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010162a:	ff 45 f0             	incl   -0x10(%ebp)
8010162d:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101634:	7f 17                	jg     8010164d <balloc+0x10a>
80101636:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101639:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010163c:	01 d0                	add    %edx,%eax
8010163e:	89 c2                	mov    %eax,%edx
80101640:	a1 e0 1c 11 80       	mov    0x80111ce0,%eax
80101645:	39 c2                	cmp    %eax,%edx
80101647:	0f 82 45 ff ff ff    	jb     80101592 <balloc+0x4f>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
8010164d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101650:	89 04 24             	mov    %eax,(%esp)
80101653:	e8 d4 eb ff ff       	call   8010022c <brelse>
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
80101658:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010165f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101662:	a1 e0 1c 11 80       	mov    0x80111ce0,%eax
80101667:	39 c2                	cmp    %eax,%edx
80101669:	0f 82 ed fe ff ff    	jb     8010155c <balloc+0x19>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
8010166f:	c7 04 24 60 89 10 80 	movl   $0x80108960,(%esp)
80101676:	e8 d9 ee ff ff       	call   80100554 <panic>
}
8010167b:	c9                   	leave  
8010167c:	c3                   	ret    

8010167d <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
8010167d:	55                   	push   %ebp
8010167e:	89 e5                	mov    %esp,%ebp
80101680:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
80101683:	c7 44 24 04 e0 1c 11 	movl   $0x80111ce0,0x4(%esp)
8010168a:	80 
8010168b:	8b 45 08             	mov    0x8(%ebp),%eax
8010168e:	89 04 24             	mov    %eax,(%esp)
80101691:	e8 16 fe ff ff       	call   801014ac <readsb>
  bp = bread(dev, BBLOCK(b, sb));
80101696:	8b 45 0c             	mov    0xc(%ebp),%eax
80101699:	c1 e8 0c             	shr    $0xc,%eax
8010169c:	89 c2                	mov    %eax,%edx
8010169e:	a1 f8 1c 11 80       	mov    0x80111cf8,%eax
801016a3:	01 c2                	add    %eax,%edx
801016a5:	8b 45 08             	mov    0x8(%ebp),%eax
801016a8:	89 54 24 04          	mov    %edx,0x4(%esp)
801016ac:	89 04 24             	mov    %eax,(%esp)
801016af:	e8 01 eb ff ff       	call   801001b5 <bread>
801016b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801016b7:	8b 45 0c             	mov    0xc(%ebp),%eax
801016ba:	25 ff 0f 00 00       	and    $0xfff,%eax
801016bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801016c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016c5:	25 07 00 00 80       	and    $0x80000007,%eax
801016ca:	85 c0                	test   %eax,%eax
801016cc:	79 05                	jns    801016d3 <bfree+0x56>
801016ce:	48                   	dec    %eax
801016cf:	83 c8 f8             	or     $0xfffffff8,%eax
801016d2:	40                   	inc    %eax
801016d3:	ba 01 00 00 00       	mov    $0x1,%edx
801016d8:	88 c1                	mov    %al,%cl
801016da:	d3 e2                	shl    %cl,%edx
801016dc:	89 d0                	mov    %edx,%eax
801016de:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801016e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016e4:	85 c0                	test   %eax,%eax
801016e6:	79 03                	jns    801016eb <bfree+0x6e>
801016e8:	83 c0 07             	add    $0x7,%eax
801016eb:	c1 f8 03             	sar    $0x3,%eax
801016ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016f1:	8a 44 02 5c          	mov    0x5c(%edx,%eax,1),%al
801016f5:	0f b6 c0             	movzbl %al,%eax
801016f8:	23 45 ec             	and    -0x14(%ebp),%eax
801016fb:	85 c0                	test   %eax,%eax
801016fd:	75 0c                	jne    8010170b <bfree+0x8e>
    panic("freeing free block");
801016ff:	c7 04 24 76 89 10 80 	movl   $0x80108976,(%esp)
80101706:	e8 49 ee ff ff       	call   80100554 <panic>
  bp->data[bi/8] &= ~m;
8010170b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010170e:	85 c0                	test   %eax,%eax
80101710:	79 03                	jns    80101715 <bfree+0x98>
80101712:	83 c0 07             	add    $0x7,%eax
80101715:	c1 f8 03             	sar    $0x3,%eax
80101718:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010171b:	8a 54 02 5c          	mov    0x5c(%edx,%eax,1),%dl
8010171f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80101722:	f7 d1                	not    %ecx
80101724:	21 ca                	and    %ecx,%edx
80101726:	88 d1                	mov    %dl,%cl
80101728:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010172b:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
8010172f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101732:	89 04 24             	mov    %eax,(%esp)
80101735:	e8 71 20 00 00       	call   801037ab <log_write>
  brelse(bp);
8010173a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010173d:	89 04 24             	mov    %eax,(%esp)
80101740:	e8 e7 ea ff ff       	call   8010022c <brelse>
}
80101745:	c9                   	leave  
80101746:	c3                   	ret    

80101747 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101747:	55                   	push   %ebp
80101748:	89 e5                	mov    %esp,%ebp
8010174a:	57                   	push   %edi
8010174b:	56                   	push   %esi
8010174c:	53                   	push   %ebx
8010174d:	83 ec 4c             	sub    $0x4c,%esp
  int i = 0;
80101750:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
80101757:	c7 44 24 04 89 89 10 	movl   $0x80108989,0x4(%esp)
8010175e:	80 
8010175f:	c7 04 24 00 1d 11 80 	movl   $0x80111d00,(%esp)
80101766:	e8 2f 37 00 00       	call   80104e9a <initlock>
  for(i = 0; i < NINODE; i++) {
8010176b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101772:	eb 2b                	jmp    8010179f <iinit+0x58>
    initsleeplock(&icache.inode[i].lock, "inode");
80101774:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101777:	89 d0                	mov    %edx,%eax
80101779:	c1 e0 03             	shl    $0x3,%eax
8010177c:	01 d0                	add    %edx,%eax
8010177e:	c1 e0 04             	shl    $0x4,%eax
80101781:	83 c0 30             	add    $0x30,%eax
80101784:	05 00 1d 11 80       	add    $0x80111d00,%eax
80101789:	83 c0 10             	add    $0x10,%eax
8010178c:	c7 44 24 04 90 89 10 	movl   $0x80108990,0x4(%esp)
80101793:	80 
80101794:	89 04 24             	mov    %eax,(%esp)
80101797:	e8 c0 35 00 00       	call   80104d5c <initsleeplock>
iinit(int dev)
{
  int i = 0;
  
  initlock(&icache.lock, "icache");
  for(i = 0; i < NINODE; i++) {
8010179c:	ff 45 e4             	incl   -0x1c(%ebp)
8010179f:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801017a3:	7e cf                	jle    80101774 <iinit+0x2d>
    initsleeplock(&icache.inode[i].lock, "inode");
  }

  readsb(dev, &sb);
801017a5:	c7 44 24 04 e0 1c 11 	movl   $0x80111ce0,0x4(%esp)
801017ac:	80 
801017ad:	8b 45 08             	mov    0x8(%ebp),%eax
801017b0:	89 04 24             	mov    %eax,(%esp)
801017b3:	e8 f4 fc ff ff       	call   801014ac <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801017b8:	a1 f8 1c 11 80       	mov    0x80111cf8,%eax
801017bd:	8b 3d f4 1c 11 80    	mov    0x80111cf4,%edi
801017c3:	8b 35 f0 1c 11 80    	mov    0x80111cf0,%esi
801017c9:	8b 1d ec 1c 11 80    	mov    0x80111cec,%ebx
801017cf:	8b 0d e8 1c 11 80    	mov    0x80111ce8,%ecx
801017d5:	8b 15 e4 1c 11 80    	mov    0x80111ce4,%edx
801017db:	89 55 d4             	mov    %edx,-0x2c(%ebp)
801017de:	8b 15 e0 1c 11 80    	mov    0x80111ce0,%edx
801017e4:	89 44 24 1c          	mov    %eax,0x1c(%esp)
801017e8:	89 7c 24 18          	mov    %edi,0x18(%esp)
801017ec:	89 74 24 14          	mov    %esi,0x14(%esp)
801017f0:	89 5c 24 10          	mov    %ebx,0x10(%esp)
801017f4:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801017f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801017fb:	89 44 24 08          	mov    %eax,0x8(%esp)
801017ff:	89 d0                	mov    %edx,%eax
80101801:	89 44 24 04          	mov    %eax,0x4(%esp)
80101805:	c7 04 24 98 89 10 80 	movl   $0x80108998,(%esp)
8010180c:	e8 b0 eb ff ff       	call   801003c1 <cprintf>
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
80101811:	83 c4 4c             	add    $0x4c,%esp
80101814:	5b                   	pop    %ebx
80101815:	5e                   	pop    %esi
80101816:	5f                   	pop    %edi
80101817:	5d                   	pop    %ebp
80101818:	c3                   	ret    

80101819 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
80101819:	55                   	push   %ebp
8010181a:	89 e5                	mov    %esp,%ebp
8010181c:	83 ec 28             	sub    $0x28,%esp
8010181f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101822:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101826:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
8010182d:	e9 9b 00 00 00       	jmp    801018cd <ialloc+0xb4>
    bp = bread(dev, IBLOCK(inum, sb));
80101832:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101835:	c1 e8 03             	shr    $0x3,%eax
80101838:	89 c2                	mov    %eax,%edx
8010183a:	a1 f4 1c 11 80       	mov    0x80111cf4,%eax
8010183f:	01 d0                	add    %edx,%eax
80101841:	89 44 24 04          	mov    %eax,0x4(%esp)
80101845:	8b 45 08             	mov    0x8(%ebp),%eax
80101848:	89 04 24             	mov    %eax,(%esp)
8010184b:	e8 65 e9 ff ff       	call   801001b5 <bread>
80101850:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101853:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101856:	8d 50 5c             	lea    0x5c(%eax),%edx
80101859:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010185c:	83 e0 07             	and    $0x7,%eax
8010185f:	c1 e0 06             	shl    $0x6,%eax
80101862:	01 d0                	add    %edx,%eax
80101864:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101867:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010186a:	8b 00                	mov    (%eax),%eax
8010186c:	66 85 c0             	test   %ax,%ax
8010186f:	75 4e                	jne    801018bf <ialloc+0xa6>
      memset(dip, 0, sizeof(*dip));
80101871:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
80101878:	00 
80101879:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101880:	00 
80101881:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101884:	89 04 24             	mov    %eax,(%esp)
80101887:	e8 92 38 00 00       	call   8010511e <memset>
      dip->type = type;
8010188c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010188f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101892:	66 89 02             	mov    %ax,(%edx)
      log_write(bp);   // mark it allocated on the disk
80101895:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101898:	89 04 24             	mov    %eax,(%esp)
8010189b:	e8 0b 1f 00 00       	call   801037ab <log_write>
      brelse(bp);
801018a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018a3:	89 04 24             	mov    %eax,(%esp)
801018a6:	e8 81 e9 ff ff       	call   8010022c <brelse>
      return iget(dev, inum);
801018ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ae:	89 44 24 04          	mov    %eax,0x4(%esp)
801018b2:	8b 45 08             	mov    0x8(%ebp),%eax
801018b5:	89 04 24             	mov    %eax,(%esp)
801018b8:	e8 ea 00 00 00       	call   801019a7 <iget>
801018bd:	eb 2a                	jmp    801018e9 <ialloc+0xd0>
    }
    brelse(bp);
801018bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018c2:	89 04 24             	mov    %eax,(%esp)
801018c5:	e8 62 e9 ff ff       	call   8010022c <brelse>
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801018ca:	ff 45 f4             	incl   -0xc(%ebp)
801018cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801018d0:	a1 e8 1c 11 80       	mov    0x80111ce8,%eax
801018d5:	39 c2                	cmp    %eax,%edx
801018d7:	0f 82 55 ff ff ff    	jb     80101832 <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
801018dd:	c7 04 24 eb 89 10 80 	movl   $0x801089eb,(%esp)
801018e4:	e8 6b ec ff ff       	call   80100554 <panic>
}
801018e9:	c9                   	leave  
801018ea:	c3                   	ret    

801018eb <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
801018eb:	55                   	push   %ebp
801018ec:	89 e5                	mov    %esp,%ebp
801018ee:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801018f1:	8b 45 08             	mov    0x8(%ebp),%eax
801018f4:	8b 40 04             	mov    0x4(%eax),%eax
801018f7:	c1 e8 03             	shr    $0x3,%eax
801018fa:	89 c2                	mov    %eax,%edx
801018fc:	a1 f4 1c 11 80       	mov    0x80111cf4,%eax
80101901:	01 c2                	add    %eax,%edx
80101903:	8b 45 08             	mov    0x8(%ebp),%eax
80101906:	8b 00                	mov    (%eax),%eax
80101908:	89 54 24 04          	mov    %edx,0x4(%esp)
8010190c:	89 04 24             	mov    %eax,(%esp)
8010190f:	e8 a1 e8 ff ff       	call   801001b5 <bread>
80101914:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101917:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010191a:	8d 50 5c             	lea    0x5c(%eax),%edx
8010191d:	8b 45 08             	mov    0x8(%ebp),%eax
80101920:	8b 40 04             	mov    0x4(%eax),%eax
80101923:	83 e0 07             	and    $0x7,%eax
80101926:	c1 e0 06             	shl    $0x6,%eax
80101929:	01 d0                	add    %edx,%eax
8010192b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
8010192e:	8b 45 08             	mov    0x8(%ebp),%eax
80101931:	8b 40 50             	mov    0x50(%eax),%eax
80101934:	8b 55 f0             	mov    -0x10(%ebp),%edx
80101937:	66 89 02             	mov    %ax,(%edx)
  dip->major = ip->major;
8010193a:	8b 45 08             	mov    0x8(%ebp),%eax
8010193d:	66 8b 40 52          	mov    0x52(%eax),%ax
80101941:	8b 55 f0             	mov    -0x10(%ebp),%edx
80101944:	66 89 42 02          	mov    %ax,0x2(%edx)
  dip->minor = ip->minor;
80101948:	8b 45 08             	mov    0x8(%ebp),%eax
8010194b:	8b 40 54             	mov    0x54(%eax),%eax
8010194e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80101951:	66 89 42 04          	mov    %ax,0x4(%edx)
  dip->nlink = ip->nlink;
80101955:	8b 45 08             	mov    0x8(%ebp),%eax
80101958:	66 8b 40 56          	mov    0x56(%eax),%ax
8010195c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010195f:	66 89 42 06          	mov    %ax,0x6(%edx)
  dip->size = ip->size;
80101963:	8b 45 08             	mov    0x8(%ebp),%eax
80101966:	8b 50 58             	mov    0x58(%eax),%edx
80101969:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010196c:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010196f:	8b 45 08             	mov    0x8(%ebp),%eax
80101972:	8d 50 5c             	lea    0x5c(%eax),%edx
80101975:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101978:	83 c0 0c             	add    $0xc,%eax
8010197b:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101982:	00 
80101983:	89 54 24 04          	mov    %edx,0x4(%esp)
80101987:	89 04 24             	mov    %eax,(%esp)
8010198a:	e8 58 38 00 00       	call   801051e7 <memmove>
  log_write(bp);
8010198f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101992:	89 04 24             	mov    %eax,(%esp)
80101995:	e8 11 1e 00 00       	call   801037ab <log_write>
  brelse(bp);
8010199a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010199d:	89 04 24             	mov    %eax,(%esp)
801019a0:	e8 87 e8 ff ff       	call   8010022c <brelse>
}
801019a5:	c9                   	leave  
801019a6:	c3                   	ret    

801019a7 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801019a7:	55                   	push   %ebp
801019a8:	89 e5                	mov    %esp,%ebp
801019aa:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801019ad:	c7 04 24 00 1d 11 80 	movl   $0x80111d00,(%esp)
801019b4:	e8 02 35 00 00       	call   80104ebb <acquire>

  // Is the inode already cached?
  empty = 0;
801019b9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801019c0:	c7 45 f4 34 1d 11 80 	movl   $0x80111d34,-0xc(%ebp)
801019c7:	eb 5c                	jmp    80101a25 <iget+0x7e>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801019c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019cc:	8b 40 08             	mov    0x8(%eax),%eax
801019cf:	85 c0                	test   %eax,%eax
801019d1:	7e 35                	jle    80101a08 <iget+0x61>
801019d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019d6:	8b 00                	mov    (%eax),%eax
801019d8:	3b 45 08             	cmp    0x8(%ebp),%eax
801019db:	75 2b                	jne    80101a08 <iget+0x61>
801019dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019e0:	8b 40 04             	mov    0x4(%eax),%eax
801019e3:	3b 45 0c             	cmp    0xc(%ebp),%eax
801019e6:	75 20                	jne    80101a08 <iget+0x61>
      ip->ref++;
801019e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019eb:	8b 40 08             	mov    0x8(%eax),%eax
801019ee:	8d 50 01             	lea    0x1(%eax),%edx
801019f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019f4:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
801019f7:	c7 04 24 00 1d 11 80 	movl   $0x80111d00,(%esp)
801019fe:	e8 22 35 00 00       	call   80104f25 <release>
      return ip;
80101a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a06:	eb 72                	jmp    80101a7a <iget+0xd3>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101a08:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101a0c:	75 10                	jne    80101a1e <iget+0x77>
80101a0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a11:	8b 40 08             	mov    0x8(%eax),%eax
80101a14:	85 c0                	test   %eax,%eax
80101a16:	75 06                	jne    80101a1e <iget+0x77>
      empty = ip;
80101a18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a1b:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101a1e:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101a25:	81 7d f4 54 39 11 80 	cmpl   $0x80113954,-0xc(%ebp)
80101a2c:	72 9b                	jb     801019c9 <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101a2e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101a32:	75 0c                	jne    80101a40 <iget+0x99>
    panic("iget: no inodes");
80101a34:	c7 04 24 fd 89 10 80 	movl   $0x801089fd,(%esp)
80101a3b:	e8 14 eb ff ff       	call   80100554 <panic>

  ip = empty;
80101a40:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a43:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101a46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a49:	8b 55 08             	mov    0x8(%ebp),%edx
80101a4c:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101a4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a51:	8b 55 0c             	mov    0xc(%ebp),%edx
80101a54:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101a57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a5a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a64:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
80101a6b:	c7 04 24 00 1d 11 80 	movl   $0x80111d00,(%esp)
80101a72:	e8 ae 34 00 00       	call   80104f25 <release>

  return ip;
80101a77:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101a7a:	c9                   	leave  
80101a7b:	c3                   	ret    

80101a7c <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101a7c:	55                   	push   %ebp
80101a7d:	89 e5                	mov    %esp,%ebp
80101a7f:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101a82:	c7 04 24 00 1d 11 80 	movl   $0x80111d00,(%esp)
80101a89:	e8 2d 34 00 00       	call   80104ebb <acquire>
  ip->ref++;
80101a8e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a91:	8b 40 08             	mov    0x8(%eax),%eax
80101a94:	8d 50 01             	lea    0x1(%eax),%edx
80101a97:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9a:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101a9d:	c7 04 24 00 1d 11 80 	movl   $0x80111d00,(%esp)
80101aa4:	e8 7c 34 00 00       	call   80104f25 <release>
  return ip;
80101aa9:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101aac:	c9                   	leave  
80101aad:	c3                   	ret    

80101aae <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101aae:	55                   	push   %ebp
80101aaf:	89 e5                	mov    %esp,%ebp
80101ab1:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101ab4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101ab8:	74 0a                	je     80101ac4 <ilock+0x16>
80101aba:	8b 45 08             	mov    0x8(%ebp),%eax
80101abd:	8b 40 08             	mov    0x8(%eax),%eax
80101ac0:	85 c0                	test   %eax,%eax
80101ac2:	7f 0c                	jg     80101ad0 <ilock+0x22>
    panic("ilock");
80101ac4:	c7 04 24 0d 8a 10 80 	movl   $0x80108a0d,(%esp)
80101acb:	e8 84 ea ff ff       	call   80100554 <panic>

  acquiresleep(&ip->lock);
80101ad0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad3:	83 c0 0c             	add    $0xc,%eax
80101ad6:	89 04 24             	mov    %eax,(%esp)
80101ad9:	e8 b8 32 00 00       	call   80104d96 <acquiresleep>

  if(ip->valid == 0){
80101ade:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae1:	8b 40 4c             	mov    0x4c(%eax),%eax
80101ae4:	85 c0                	test   %eax,%eax
80101ae6:	0f 85 ca 00 00 00    	jne    80101bb6 <ilock+0x108>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101aec:	8b 45 08             	mov    0x8(%ebp),%eax
80101aef:	8b 40 04             	mov    0x4(%eax),%eax
80101af2:	c1 e8 03             	shr    $0x3,%eax
80101af5:	89 c2                	mov    %eax,%edx
80101af7:	a1 f4 1c 11 80       	mov    0x80111cf4,%eax
80101afc:	01 c2                	add    %eax,%edx
80101afe:	8b 45 08             	mov    0x8(%ebp),%eax
80101b01:	8b 00                	mov    (%eax),%eax
80101b03:	89 54 24 04          	mov    %edx,0x4(%esp)
80101b07:	89 04 24             	mov    %eax,(%esp)
80101b0a:	e8 a6 e6 ff ff       	call   801001b5 <bread>
80101b0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101b12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b15:	8d 50 5c             	lea    0x5c(%eax),%edx
80101b18:	8b 45 08             	mov    0x8(%ebp),%eax
80101b1b:	8b 40 04             	mov    0x4(%eax),%eax
80101b1e:	83 e0 07             	and    $0x7,%eax
80101b21:	c1 e0 06             	shl    $0x6,%eax
80101b24:	01 d0                	add    %edx,%eax
80101b26:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101b29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b2c:	8b 00                	mov    (%eax),%eax
80101b2e:	8b 55 08             	mov    0x8(%ebp),%edx
80101b31:	66 89 42 50          	mov    %ax,0x50(%edx)
    ip->major = dip->major;
80101b35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b38:	66 8b 40 02          	mov    0x2(%eax),%ax
80101b3c:	8b 55 08             	mov    0x8(%ebp),%edx
80101b3f:	66 89 42 52          	mov    %ax,0x52(%edx)
    ip->minor = dip->minor;
80101b43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b46:	8b 40 04             	mov    0x4(%eax),%eax
80101b49:	8b 55 08             	mov    0x8(%ebp),%edx
80101b4c:	66 89 42 54          	mov    %ax,0x54(%edx)
    ip->nlink = dip->nlink;
80101b50:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b53:	66 8b 40 06          	mov    0x6(%eax),%ax
80101b57:	8b 55 08             	mov    0x8(%ebp),%edx
80101b5a:	66 89 42 56          	mov    %ax,0x56(%edx)
    ip->size = dip->size;
80101b5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b61:	8b 50 08             	mov    0x8(%eax),%edx
80101b64:	8b 45 08             	mov    0x8(%ebp),%eax
80101b67:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101b6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b6d:	8d 50 0c             	lea    0xc(%eax),%edx
80101b70:	8b 45 08             	mov    0x8(%ebp),%eax
80101b73:	83 c0 5c             	add    $0x5c,%eax
80101b76:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101b7d:	00 
80101b7e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101b82:	89 04 24             	mov    %eax,(%esp)
80101b85:	e8 5d 36 00 00       	call   801051e7 <memmove>
    brelse(bp);
80101b8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b8d:	89 04 24             	mov    %eax,(%esp)
80101b90:	e8 97 e6 ff ff       	call   8010022c <brelse>
    ip->valid = 1;
80101b95:	8b 45 08             	mov    0x8(%ebp),%eax
80101b98:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101b9f:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba2:	8b 40 50             	mov    0x50(%eax),%eax
80101ba5:	66 85 c0             	test   %ax,%ax
80101ba8:	75 0c                	jne    80101bb6 <ilock+0x108>
      panic("ilock: no type");
80101baa:	c7 04 24 13 8a 10 80 	movl   $0x80108a13,(%esp)
80101bb1:	e8 9e e9 ff ff       	call   80100554 <panic>
  }
}
80101bb6:	c9                   	leave  
80101bb7:	c3                   	ret    

80101bb8 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101bb8:	55                   	push   %ebp
80101bb9:	89 e5                	mov    %esp,%ebp
80101bbb:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101bbe:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101bc2:	74 1c                	je     80101be0 <iunlock+0x28>
80101bc4:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc7:	83 c0 0c             	add    $0xc,%eax
80101bca:	89 04 24             	mov    %eax,(%esp)
80101bcd:	e8 61 32 00 00       	call   80104e33 <holdingsleep>
80101bd2:	85 c0                	test   %eax,%eax
80101bd4:	74 0a                	je     80101be0 <iunlock+0x28>
80101bd6:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd9:	8b 40 08             	mov    0x8(%eax),%eax
80101bdc:	85 c0                	test   %eax,%eax
80101bde:	7f 0c                	jg     80101bec <iunlock+0x34>
    panic("iunlock");
80101be0:	c7 04 24 22 8a 10 80 	movl   $0x80108a22,(%esp)
80101be7:	e8 68 e9 ff ff       	call   80100554 <panic>

  releasesleep(&ip->lock);
80101bec:	8b 45 08             	mov    0x8(%ebp),%eax
80101bef:	83 c0 0c             	add    $0xc,%eax
80101bf2:	89 04 24             	mov    %eax,(%esp)
80101bf5:	e8 f7 31 00 00       	call   80104df1 <releasesleep>
}
80101bfa:	c9                   	leave  
80101bfb:	c3                   	ret    

80101bfc <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101bfc:	55                   	push   %ebp
80101bfd:	89 e5                	mov    %esp,%ebp
80101bff:	83 ec 28             	sub    $0x28,%esp
  acquiresleep(&ip->lock);
80101c02:	8b 45 08             	mov    0x8(%ebp),%eax
80101c05:	83 c0 0c             	add    $0xc,%eax
80101c08:	89 04 24             	mov    %eax,(%esp)
80101c0b:	e8 86 31 00 00       	call   80104d96 <acquiresleep>
  if(ip->valid && ip->nlink == 0){
80101c10:	8b 45 08             	mov    0x8(%ebp),%eax
80101c13:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c16:	85 c0                	test   %eax,%eax
80101c18:	74 5c                	je     80101c76 <iput+0x7a>
80101c1a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c1d:	66 8b 40 56          	mov    0x56(%eax),%ax
80101c21:	66 85 c0             	test   %ax,%ax
80101c24:	75 50                	jne    80101c76 <iput+0x7a>
    acquire(&icache.lock);
80101c26:	c7 04 24 00 1d 11 80 	movl   $0x80111d00,(%esp)
80101c2d:	e8 89 32 00 00       	call   80104ebb <acquire>
    int r = ip->ref;
80101c32:	8b 45 08             	mov    0x8(%ebp),%eax
80101c35:	8b 40 08             	mov    0x8(%eax),%eax
80101c38:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101c3b:	c7 04 24 00 1d 11 80 	movl   $0x80111d00,(%esp)
80101c42:	e8 de 32 00 00       	call   80104f25 <release>
    if(r == 1){
80101c47:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101c4b:	75 29                	jne    80101c76 <iput+0x7a>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101c4d:	8b 45 08             	mov    0x8(%ebp),%eax
80101c50:	89 04 24             	mov    %eax,(%esp)
80101c53:	e8 86 01 00 00       	call   80101dde <itrunc>
      ip->type = 0;
80101c58:	8b 45 08             	mov    0x8(%ebp),%eax
80101c5b:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101c61:	8b 45 08             	mov    0x8(%ebp),%eax
80101c64:	89 04 24             	mov    %eax,(%esp)
80101c67:	e8 7f fc ff ff       	call   801018eb <iupdate>
      ip->valid = 0;
80101c6c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c6f:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101c76:	8b 45 08             	mov    0x8(%ebp),%eax
80101c79:	83 c0 0c             	add    $0xc,%eax
80101c7c:	89 04 24             	mov    %eax,(%esp)
80101c7f:	e8 6d 31 00 00       	call   80104df1 <releasesleep>

  acquire(&icache.lock);
80101c84:	c7 04 24 00 1d 11 80 	movl   $0x80111d00,(%esp)
80101c8b:	e8 2b 32 00 00       	call   80104ebb <acquire>
  ip->ref--;
80101c90:	8b 45 08             	mov    0x8(%ebp),%eax
80101c93:	8b 40 08             	mov    0x8(%eax),%eax
80101c96:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c99:	8b 45 08             	mov    0x8(%ebp),%eax
80101c9c:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c9f:	c7 04 24 00 1d 11 80 	movl   $0x80111d00,(%esp)
80101ca6:	e8 7a 32 00 00       	call   80104f25 <release>
}
80101cab:	c9                   	leave  
80101cac:	c3                   	ret    

80101cad <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101cad:	55                   	push   %ebp
80101cae:	89 e5                	mov    %esp,%ebp
80101cb0:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101cb3:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb6:	89 04 24             	mov    %eax,(%esp)
80101cb9:	e8 fa fe ff ff       	call   80101bb8 <iunlock>
  iput(ip);
80101cbe:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc1:	89 04 24             	mov    %eax,(%esp)
80101cc4:	e8 33 ff ff ff       	call   80101bfc <iput>
}
80101cc9:	c9                   	leave  
80101cca:	c3                   	ret    

80101ccb <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101ccb:	55                   	push   %ebp
80101ccc:	89 e5                	mov    %esp,%ebp
80101cce:	53                   	push   %ebx
80101ccf:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101cd2:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101cd6:	77 3e                	ja     80101d16 <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101cd8:	8b 45 08             	mov    0x8(%ebp),%eax
80101cdb:	8b 55 0c             	mov    0xc(%ebp),%edx
80101cde:	83 c2 14             	add    $0x14,%edx
80101ce1:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101ce5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ce8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cec:	75 20                	jne    80101d0e <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101cee:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf1:	8b 00                	mov    (%eax),%eax
80101cf3:	89 04 24             	mov    %eax,(%esp)
80101cf6:	e8 48 f8 ff ff       	call   80101543 <balloc>
80101cfb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cfe:	8b 45 08             	mov    0x8(%ebp),%eax
80101d01:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d04:	8d 4a 14             	lea    0x14(%edx),%ecx
80101d07:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d0a:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101d0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d11:	e9 c2 00 00 00       	jmp    80101dd8 <bmap+0x10d>
  }
  bn -= NDIRECT;
80101d16:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101d1a:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101d1e:	0f 87 a8 00 00 00    	ja     80101dcc <bmap+0x101>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101d24:	8b 45 08             	mov    0x8(%ebp),%eax
80101d27:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101d2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d30:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d34:	75 1c                	jne    80101d52 <bmap+0x87>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101d36:	8b 45 08             	mov    0x8(%ebp),%eax
80101d39:	8b 00                	mov    (%eax),%eax
80101d3b:	89 04 24             	mov    %eax,(%esp)
80101d3e:	e8 00 f8 ff ff       	call   80101543 <balloc>
80101d43:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d46:	8b 45 08             	mov    0x8(%ebp),%eax
80101d49:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d4c:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101d52:	8b 45 08             	mov    0x8(%ebp),%eax
80101d55:	8b 00                	mov    (%eax),%eax
80101d57:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d5a:	89 54 24 04          	mov    %edx,0x4(%esp)
80101d5e:	89 04 24             	mov    %eax,(%esp)
80101d61:	e8 4f e4 ff ff       	call   801001b5 <bread>
80101d66:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101d69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d6c:	83 c0 5c             	add    $0x5c,%eax
80101d6f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101d72:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d75:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d7c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d7f:	01 d0                	add    %edx,%eax
80101d81:	8b 00                	mov    (%eax),%eax
80101d83:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d86:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d8a:	75 30                	jne    80101dbc <bmap+0xf1>
      a[bn] = addr = balloc(ip->dev);
80101d8c:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d8f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d96:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d99:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101d9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d9f:	8b 00                	mov    (%eax),%eax
80101da1:	89 04 24             	mov    %eax,(%esp)
80101da4:	e8 9a f7 ff ff       	call   80101543 <balloc>
80101da9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101dac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101daf:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101db1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101db4:	89 04 24             	mov    %eax,(%esp)
80101db7:	e8 ef 19 00 00       	call   801037ab <log_write>
    }
    brelse(bp);
80101dbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101dbf:	89 04 24             	mov    %eax,(%esp)
80101dc2:	e8 65 e4 ff ff       	call   8010022c <brelse>
    return addr;
80101dc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dca:	eb 0c                	jmp    80101dd8 <bmap+0x10d>
  }

  panic("bmap: out of range");
80101dcc:	c7 04 24 2a 8a 10 80 	movl   $0x80108a2a,(%esp)
80101dd3:	e8 7c e7 ff ff       	call   80100554 <panic>
}
80101dd8:	83 c4 24             	add    $0x24,%esp
80101ddb:	5b                   	pop    %ebx
80101ddc:	5d                   	pop    %ebp
80101ddd:	c3                   	ret    

80101dde <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101dde:	55                   	push   %ebp
80101ddf:	89 e5                	mov    %esp,%ebp
80101de1:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101de4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101deb:	eb 43                	jmp    80101e30 <itrunc+0x52>
    if(ip->addrs[i]){
80101ded:	8b 45 08             	mov    0x8(%ebp),%eax
80101df0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101df3:	83 c2 14             	add    $0x14,%edx
80101df6:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101dfa:	85 c0                	test   %eax,%eax
80101dfc:	74 2f                	je     80101e2d <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101dfe:	8b 45 08             	mov    0x8(%ebp),%eax
80101e01:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e04:	83 c2 14             	add    $0x14,%edx
80101e07:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101e0b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e0e:	8b 00                	mov    (%eax),%eax
80101e10:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e14:	89 04 24             	mov    %eax,(%esp)
80101e17:	e8 61 f8 ff ff       	call   8010167d <bfree>
      ip->addrs[i] = 0;
80101e1c:	8b 45 08             	mov    0x8(%ebp),%eax
80101e1f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e22:	83 c2 14             	add    $0x14,%edx
80101e25:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101e2c:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101e2d:	ff 45 f4             	incl   -0xc(%ebp)
80101e30:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101e34:	7e b7                	jle    80101ded <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }

  if(ip->addrs[NDIRECT]){
80101e36:	8b 45 08             	mov    0x8(%ebp),%eax
80101e39:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e3f:	85 c0                	test   %eax,%eax
80101e41:	0f 84 a3 00 00 00    	je     80101eea <itrunc+0x10c>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101e47:	8b 45 08             	mov    0x8(%ebp),%eax
80101e4a:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101e50:	8b 45 08             	mov    0x8(%ebp),%eax
80101e53:	8b 00                	mov    (%eax),%eax
80101e55:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e59:	89 04 24             	mov    %eax,(%esp)
80101e5c:	e8 54 e3 ff ff       	call   801001b5 <bread>
80101e61:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101e64:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e67:	83 c0 5c             	add    $0x5c,%eax
80101e6a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101e6d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101e74:	eb 3a                	jmp    80101eb0 <itrunc+0xd2>
      if(a[j])
80101e76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e79:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e80:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e83:	01 d0                	add    %edx,%eax
80101e85:	8b 00                	mov    (%eax),%eax
80101e87:	85 c0                	test   %eax,%eax
80101e89:	74 22                	je     80101ead <itrunc+0xcf>
        bfree(ip->dev, a[j]);
80101e8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e8e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e95:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e98:	01 d0                	add    %edx,%eax
80101e9a:	8b 10                	mov    (%eax),%edx
80101e9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101e9f:	8b 00                	mov    (%eax),%eax
80101ea1:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ea5:	89 04 24             	mov    %eax,(%esp)
80101ea8:	e8 d0 f7 ff ff       	call   8010167d <bfree>
  }

  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101ead:	ff 45 f0             	incl   -0x10(%ebp)
80101eb0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101eb3:	83 f8 7f             	cmp    $0x7f,%eax
80101eb6:	76 be                	jbe    80101e76 <itrunc+0x98>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101eb8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ebb:	89 04 24             	mov    %eax,(%esp)
80101ebe:	e8 69 e3 ff ff       	call   8010022c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101ec3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec6:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101ecc:	8b 45 08             	mov    0x8(%ebp),%eax
80101ecf:	8b 00                	mov    (%eax),%eax
80101ed1:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ed5:	89 04 24             	mov    %eax,(%esp)
80101ed8:	e8 a0 f7 ff ff       	call   8010167d <bfree>
    ip->addrs[NDIRECT] = 0;
80101edd:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee0:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101ee7:	00 00 00 
  }

  ip->size = 0;
80101eea:	8b 45 08             	mov    0x8(%ebp),%eax
80101eed:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101ef4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef7:	89 04 24             	mov    %eax,(%esp)
80101efa:	e8 ec f9 ff ff       	call   801018eb <iupdate>
}
80101eff:	c9                   	leave  
80101f00:	c3                   	ret    

80101f01 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101f01:	55                   	push   %ebp
80101f02:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101f04:	8b 45 08             	mov    0x8(%ebp),%eax
80101f07:	8b 00                	mov    (%eax),%eax
80101f09:	89 c2                	mov    %eax,%edx
80101f0b:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f0e:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101f11:	8b 45 08             	mov    0x8(%ebp),%eax
80101f14:	8b 50 04             	mov    0x4(%eax),%edx
80101f17:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f1a:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101f1d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f20:	8b 40 50             	mov    0x50(%eax),%eax
80101f23:	8b 55 0c             	mov    0xc(%ebp),%edx
80101f26:	66 89 02             	mov    %ax,(%edx)
  st->nlink = ip->nlink;
80101f29:	8b 45 08             	mov    0x8(%ebp),%eax
80101f2c:	66 8b 40 56          	mov    0x56(%eax),%ax
80101f30:	8b 55 0c             	mov    0xc(%ebp),%edx
80101f33:	66 89 42 0c          	mov    %ax,0xc(%edx)
  st->size = ip->size;
80101f37:	8b 45 08             	mov    0x8(%ebp),%eax
80101f3a:	8b 50 58             	mov    0x58(%eax),%edx
80101f3d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f40:	89 50 10             	mov    %edx,0x10(%eax)
}
80101f43:	5d                   	pop    %ebp
80101f44:	c3                   	ret    

80101f45 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101f45:	55                   	push   %ebp
80101f46:	89 e5                	mov    %esp,%ebp
80101f48:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101f4b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f4e:	8b 40 50             	mov    0x50(%eax),%eax
80101f51:	66 83 f8 03          	cmp    $0x3,%ax
80101f55:	75 60                	jne    80101fb7 <readi+0x72>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101f57:	8b 45 08             	mov    0x8(%ebp),%eax
80101f5a:	66 8b 40 52          	mov    0x52(%eax),%ax
80101f5e:	66 85 c0             	test   %ax,%ax
80101f61:	78 20                	js     80101f83 <readi+0x3e>
80101f63:	8b 45 08             	mov    0x8(%ebp),%eax
80101f66:	66 8b 40 52          	mov    0x52(%eax),%ax
80101f6a:	66 83 f8 09          	cmp    $0x9,%ax
80101f6e:	7f 13                	jg     80101f83 <readi+0x3e>
80101f70:	8b 45 08             	mov    0x8(%ebp),%eax
80101f73:	66 8b 40 52          	mov    0x52(%eax),%ax
80101f77:	98                   	cwtl   
80101f78:	8b 04 c5 80 1c 11 80 	mov    -0x7feee380(,%eax,8),%eax
80101f7f:	85 c0                	test   %eax,%eax
80101f81:	75 0a                	jne    80101f8d <readi+0x48>
      return -1;
80101f83:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f88:	e9 1a 01 00 00       	jmp    801020a7 <readi+0x162>
    return devsw[ip->major].read(ip, dst, n);
80101f8d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f90:	66 8b 40 52          	mov    0x52(%eax),%ax
80101f94:	98                   	cwtl   
80101f95:	8b 04 c5 80 1c 11 80 	mov    -0x7feee380(,%eax,8),%eax
80101f9c:	8b 55 14             	mov    0x14(%ebp),%edx
80101f9f:	89 54 24 08          	mov    %edx,0x8(%esp)
80101fa3:	8b 55 0c             	mov    0xc(%ebp),%edx
80101fa6:	89 54 24 04          	mov    %edx,0x4(%esp)
80101faa:	8b 55 08             	mov    0x8(%ebp),%edx
80101fad:	89 14 24             	mov    %edx,(%esp)
80101fb0:	ff d0                	call   *%eax
80101fb2:	e9 f0 00 00 00       	jmp    801020a7 <readi+0x162>
  }

  if(off > ip->size || off + n < off)
80101fb7:	8b 45 08             	mov    0x8(%ebp),%eax
80101fba:	8b 40 58             	mov    0x58(%eax),%eax
80101fbd:	3b 45 10             	cmp    0x10(%ebp),%eax
80101fc0:	72 0d                	jb     80101fcf <readi+0x8a>
80101fc2:	8b 45 14             	mov    0x14(%ebp),%eax
80101fc5:	8b 55 10             	mov    0x10(%ebp),%edx
80101fc8:	01 d0                	add    %edx,%eax
80101fca:	3b 45 10             	cmp    0x10(%ebp),%eax
80101fcd:	73 0a                	jae    80101fd9 <readi+0x94>
    return -1;
80101fcf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fd4:	e9 ce 00 00 00       	jmp    801020a7 <readi+0x162>
  if(off + n > ip->size)
80101fd9:	8b 45 14             	mov    0x14(%ebp),%eax
80101fdc:	8b 55 10             	mov    0x10(%ebp),%edx
80101fdf:	01 c2                	add    %eax,%edx
80101fe1:	8b 45 08             	mov    0x8(%ebp),%eax
80101fe4:	8b 40 58             	mov    0x58(%eax),%eax
80101fe7:	39 c2                	cmp    %eax,%edx
80101fe9:	76 0c                	jbe    80101ff7 <readi+0xb2>
    n = ip->size - off;
80101feb:	8b 45 08             	mov    0x8(%ebp),%eax
80101fee:	8b 40 58             	mov    0x58(%eax),%eax
80101ff1:	2b 45 10             	sub    0x10(%ebp),%eax
80101ff4:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101ff7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101ffe:	e9 95 00 00 00       	jmp    80102098 <readi+0x153>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102003:	8b 45 10             	mov    0x10(%ebp),%eax
80102006:	c1 e8 09             	shr    $0x9,%eax
80102009:	89 44 24 04          	mov    %eax,0x4(%esp)
8010200d:	8b 45 08             	mov    0x8(%ebp),%eax
80102010:	89 04 24             	mov    %eax,(%esp)
80102013:	e8 b3 fc ff ff       	call   80101ccb <bmap>
80102018:	8b 55 08             	mov    0x8(%ebp),%edx
8010201b:	8b 12                	mov    (%edx),%edx
8010201d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102021:	89 14 24             	mov    %edx,(%esp)
80102024:	e8 8c e1 ff ff       	call   801001b5 <bread>
80102029:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010202c:	8b 45 10             	mov    0x10(%ebp),%eax
8010202f:	25 ff 01 00 00       	and    $0x1ff,%eax
80102034:	89 c2                	mov    %eax,%edx
80102036:	b8 00 02 00 00       	mov    $0x200,%eax
8010203b:	29 d0                	sub    %edx,%eax
8010203d:	89 c1                	mov    %eax,%ecx
8010203f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102042:	8b 55 14             	mov    0x14(%ebp),%edx
80102045:	29 c2                	sub    %eax,%edx
80102047:	89 c8                	mov    %ecx,%eax
80102049:	39 d0                	cmp    %edx,%eax
8010204b:	76 02                	jbe    8010204f <readi+0x10a>
8010204d:	89 d0                	mov    %edx,%eax
8010204f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80102052:	8b 45 10             	mov    0x10(%ebp),%eax
80102055:	25 ff 01 00 00       	and    $0x1ff,%eax
8010205a:	8d 50 50             	lea    0x50(%eax),%edx
8010205d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102060:	01 d0                	add    %edx,%eax
80102062:	8d 50 0c             	lea    0xc(%eax),%edx
80102065:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102068:	89 44 24 08          	mov    %eax,0x8(%esp)
8010206c:	89 54 24 04          	mov    %edx,0x4(%esp)
80102070:	8b 45 0c             	mov    0xc(%ebp),%eax
80102073:	89 04 24             	mov    %eax,(%esp)
80102076:	e8 6c 31 00 00       	call   801051e7 <memmove>
    brelse(bp);
8010207b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010207e:	89 04 24             	mov    %eax,(%esp)
80102081:	e8 a6 e1 ff ff       	call   8010022c <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102086:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102089:	01 45 f4             	add    %eax,-0xc(%ebp)
8010208c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010208f:	01 45 10             	add    %eax,0x10(%ebp)
80102092:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102095:	01 45 0c             	add    %eax,0xc(%ebp)
80102098:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010209b:	3b 45 14             	cmp    0x14(%ebp),%eax
8010209e:	0f 82 5f ff ff ff    	jb     80102003 <readi+0xbe>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
801020a4:	8b 45 14             	mov    0x14(%ebp),%eax
}
801020a7:	c9                   	leave  
801020a8:	c3                   	ret    

801020a9 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
801020a9:	55                   	push   %ebp
801020aa:	89 e5                	mov    %esp,%ebp
801020ac:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801020af:	8b 45 08             	mov    0x8(%ebp),%eax
801020b2:	8b 40 50             	mov    0x50(%eax),%eax
801020b5:	66 83 f8 03          	cmp    $0x3,%ax
801020b9:	75 60                	jne    8010211b <writei+0x72>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801020bb:	8b 45 08             	mov    0x8(%ebp),%eax
801020be:	66 8b 40 52          	mov    0x52(%eax),%ax
801020c2:	66 85 c0             	test   %ax,%ax
801020c5:	78 20                	js     801020e7 <writei+0x3e>
801020c7:	8b 45 08             	mov    0x8(%ebp),%eax
801020ca:	66 8b 40 52          	mov    0x52(%eax),%ax
801020ce:	66 83 f8 09          	cmp    $0x9,%ax
801020d2:	7f 13                	jg     801020e7 <writei+0x3e>
801020d4:	8b 45 08             	mov    0x8(%ebp),%eax
801020d7:	66 8b 40 52          	mov    0x52(%eax),%ax
801020db:	98                   	cwtl   
801020dc:	8b 04 c5 84 1c 11 80 	mov    -0x7feee37c(,%eax,8),%eax
801020e3:	85 c0                	test   %eax,%eax
801020e5:	75 0a                	jne    801020f1 <writei+0x48>
      return -1;
801020e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020ec:	e9 45 01 00 00       	jmp    80102236 <writei+0x18d>
    return devsw[ip->major].write(ip, src, n);
801020f1:	8b 45 08             	mov    0x8(%ebp),%eax
801020f4:	66 8b 40 52          	mov    0x52(%eax),%ax
801020f8:	98                   	cwtl   
801020f9:	8b 04 c5 84 1c 11 80 	mov    -0x7feee37c(,%eax,8),%eax
80102100:	8b 55 14             	mov    0x14(%ebp),%edx
80102103:	89 54 24 08          	mov    %edx,0x8(%esp)
80102107:	8b 55 0c             	mov    0xc(%ebp),%edx
8010210a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010210e:	8b 55 08             	mov    0x8(%ebp),%edx
80102111:	89 14 24             	mov    %edx,(%esp)
80102114:	ff d0                	call   *%eax
80102116:	e9 1b 01 00 00       	jmp    80102236 <writei+0x18d>
  }

  if(off > ip->size || off + n < off)
8010211b:	8b 45 08             	mov    0x8(%ebp),%eax
8010211e:	8b 40 58             	mov    0x58(%eax),%eax
80102121:	3b 45 10             	cmp    0x10(%ebp),%eax
80102124:	72 0d                	jb     80102133 <writei+0x8a>
80102126:	8b 45 14             	mov    0x14(%ebp),%eax
80102129:	8b 55 10             	mov    0x10(%ebp),%edx
8010212c:	01 d0                	add    %edx,%eax
8010212e:	3b 45 10             	cmp    0x10(%ebp),%eax
80102131:	73 0a                	jae    8010213d <writei+0x94>
    return -1;
80102133:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102138:	e9 f9 00 00 00       	jmp    80102236 <writei+0x18d>
  if(off + n > MAXFILE*BSIZE)
8010213d:	8b 45 14             	mov    0x14(%ebp),%eax
80102140:	8b 55 10             	mov    0x10(%ebp),%edx
80102143:	01 d0                	add    %edx,%eax
80102145:	3d 00 18 01 00       	cmp    $0x11800,%eax
8010214a:	76 0a                	jbe    80102156 <writei+0xad>
    return -1;
8010214c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102151:	e9 e0 00 00 00       	jmp    80102236 <writei+0x18d>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102156:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010215d:	e9 a0 00 00 00       	jmp    80102202 <writei+0x159>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102162:	8b 45 10             	mov    0x10(%ebp),%eax
80102165:	c1 e8 09             	shr    $0x9,%eax
80102168:	89 44 24 04          	mov    %eax,0x4(%esp)
8010216c:	8b 45 08             	mov    0x8(%ebp),%eax
8010216f:	89 04 24             	mov    %eax,(%esp)
80102172:	e8 54 fb ff ff       	call   80101ccb <bmap>
80102177:	8b 55 08             	mov    0x8(%ebp),%edx
8010217a:	8b 12                	mov    (%edx),%edx
8010217c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102180:	89 14 24             	mov    %edx,(%esp)
80102183:	e8 2d e0 ff ff       	call   801001b5 <bread>
80102188:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010218b:	8b 45 10             	mov    0x10(%ebp),%eax
8010218e:	25 ff 01 00 00       	and    $0x1ff,%eax
80102193:	89 c2                	mov    %eax,%edx
80102195:	b8 00 02 00 00       	mov    $0x200,%eax
8010219a:	29 d0                	sub    %edx,%eax
8010219c:	89 c1                	mov    %eax,%ecx
8010219e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021a1:	8b 55 14             	mov    0x14(%ebp),%edx
801021a4:	29 c2                	sub    %eax,%edx
801021a6:	89 c8                	mov    %ecx,%eax
801021a8:	39 d0                	cmp    %edx,%eax
801021aa:	76 02                	jbe    801021ae <writei+0x105>
801021ac:	89 d0                	mov    %edx,%eax
801021ae:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801021b1:	8b 45 10             	mov    0x10(%ebp),%eax
801021b4:	25 ff 01 00 00       	and    $0x1ff,%eax
801021b9:	8d 50 50             	lea    0x50(%eax),%edx
801021bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021bf:	01 d0                	add    %edx,%eax
801021c1:	8d 50 0c             	lea    0xc(%eax),%edx
801021c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021c7:	89 44 24 08          	mov    %eax,0x8(%esp)
801021cb:	8b 45 0c             	mov    0xc(%ebp),%eax
801021ce:	89 44 24 04          	mov    %eax,0x4(%esp)
801021d2:	89 14 24             	mov    %edx,(%esp)
801021d5:	e8 0d 30 00 00       	call   801051e7 <memmove>
    log_write(bp);
801021da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021dd:	89 04 24             	mov    %eax,(%esp)
801021e0:	e8 c6 15 00 00       	call   801037ab <log_write>
    brelse(bp);
801021e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021e8:	89 04 24             	mov    %eax,(%esp)
801021eb:	e8 3c e0 ff ff       	call   8010022c <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801021f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021f3:	01 45 f4             	add    %eax,-0xc(%ebp)
801021f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021f9:	01 45 10             	add    %eax,0x10(%ebp)
801021fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021ff:	01 45 0c             	add    %eax,0xc(%ebp)
80102202:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102205:	3b 45 14             	cmp    0x14(%ebp),%eax
80102208:	0f 82 54 ff ff ff    	jb     80102162 <writei+0xb9>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
8010220e:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102212:	74 1f                	je     80102233 <writei+0x18a>
80102214:	8b 45 08             	mov    0x8(%ebp),%eax
80102217:	8b 40 58             	mov    0x58(%eax),%eax
8010221a:	3b 45 10             	cmp    0x10(%ebp),%eax
8010221d:	73 14                	jae    80102233 <writei+0x18a>
    ip->size = off;
8010221f:	8b 45 08             	mov    0x8(%ebp),%eax
80102222:	8b 55 10             	mov    0x10(%ebp),%edx
80102225:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
80102228:	8b 45 08             	mov    0x8(%ebp),%eax
8010222b:	89 04 24             	mov    %eax,(%esp)
8010222e:	e8 b8 f6 ff ff       	call   801018eb <iupdate>
  }
  return n;
80102233:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102236:	c9                   	leave  
80102237:	c3                   	ret    

80102238 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102238:	55                   	push   %ebp
80102239:	89 e5                	mov    %esp,%ebp
8010223b:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
8010223e:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102245:	00 
80102246:	8b 45 0c             	mov    0xc(%ebp),%eax
80102249:	89 44 24 04          	mov    %eax,0x4(%esp)
8010224d:	8b 45 08             	mov    0x8(%ebp),%eax
80102250:	89 04 24             	mov    %eax,(%esp)
80102253:	e8 2e 30 00 00       	call   80105286 <strncmp>
}
80102258:	c9                   	leave  
80102259:	c3                   	ret    

8010225a <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
8010225a:	55                   	push   %ebp
8010225b:	89 e5                	mov    %esp,%ebp
8010225d:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102260:	8b 45 08             	mov    0x8(%ebp),%eax
80102263:	8b 40 50             	mov    0x50(%eax),%eax
80102266:	66 83 f8 01          	cmp    $0x1,%ax
8010226a:	74 0c                	je     80102278 <dirlookup+0x1e>
    panic("dirlookup not DIR");
8010226c:	c7 04 24 3d 8a 10 80 	movl   $0x80108a3d,(%esp)
80102273:	e8 dc e2 ff ff       	call   80100554 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
80102278:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010227f:	e9 86 00 00 00       	jmp    8010230a <dirlookup+0xb0>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102284:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010228b:	00 
8010228c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010228f:	89 44 24 08          	mov    %eax,0x8(%esp)
80102293:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102296:	89 44 24 04          	mov    %eax,0x4(%esp)
8010229a:	8b 45 08             	mov    0x8(%ebp),%eax
8010229d:	89 04 24             	mov    %eax,(%esp)
801022a0:	e8 a0 fc ff ff       	call   80101f45 <readi>
801022a5:	83 f8 10             	cmp    $0x10,%eax
801022a8:	74 0c                	je     801022b6 <dirlookup+0x5c>
      panic("dirlookup read");
801022aa:	c7 04 24 4f 8a 10 80 	movl   $0x80108a4f,(%esp)
801022b1:	e8 9e e2 ff ff       	call   80100554 <panic>
    if(de.inum == 0)
801022b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801022b9:	66 85 c0             	test   %ax,%ax
801022bc:	75 02                	jne    801022c0 <dirlookup+0x66>
      continue;
801022be:	eb 46                	jmp    80102306 <dirlookup+0xac>
    if(namecmp(name, de.name) == 0){
801022c0:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022c3:	83 c0 02             	add    $0x2,%eax
801022c6:	89 44 24 04          	mov    %eax,0x4(%esp)
801022ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801022cd:	89 04 24             	mov    %eax,(%esp)
801022d0:	e8 63 ff ff ff       	call   80102238 <namecmp>
801022d5:	85 c0                	test   %eax,%eax
801022d7:	75 2d                	jne    80102306 <dirlookup+0xac>
      // entry matches path element
      if(poff)
801022d9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801022dd:	74 08                	je     801022e7 <dirlookup+0x8d>
        *poff = off;
801022df:	8b 45 10             	mov    0x10(%ebp),%eax
801022e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801022e5:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
801022e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801022ea:	0f b7 c0             	movzwl %ax,%eax
801022ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
801022f0:	8b 45 08             	mov    0x8(%ebp),%eax
801022f3:	8b 00                	mov    (%eax),%eax
801022f5:	8b 55 f0             	mov    -0x10(%ebp),%edx
801022f8:	89 54 24 04          	mov    %edx,0x4(%esp)
801022fc:	89 04 24             	mov    %eax,(%esp)
801022ff:	e8 a3 f6 ff ff       	call   801019a7 <iget>
80102304:	eb 18                	jmp    8010231e <dirlookup+0xc4>
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102306:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010230a:	8b 45 08             	mov    0x8(%ebp),%eax
8010230d:	8b 40 58             	mov    0x58(%eax),%eax
80102310:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102313:	0f 87 6b ff ff ff    	ja     80102284 <dirlookup+0x2a>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
80102319:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010231e:	c9                   	leave  
8010231f:	c3                   	ret    

80102320 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102320:	55                   	push   %ebp
80102321:	89 e5                	mov    %esp,%ebp
80102323:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102326:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010232d:	00 
8010232e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102331:	89 44 24 04          	mov    %eax,0x4(%esp)
80102335:	8b 45 08             	mov    0x8(%ebp),%eax
80102338:	89 04 24             	mov    %eax,(%esp)
8010233b:	e8 1a ff ff ff       	call   8010225a <dirlookup>
80102340:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102343:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102347:	74 15                	je     8010235e <dirlink+0x3e>
    iput(ip);
80102349:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010234c:	89 04 24             	mov    %eax,(%esp)
8010234f:	e8 a8 f8 ff ff       	call   80101bfc <iput>
    return -1;
80102354:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102359:	e9 b6 00 00 00       	jmp    80102414 <dirlink+0xf4>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
8010235e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102365:	eb 45                	jmp    801023ac <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102367:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010236a:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102371:	00 
80102372:	89 44 24 08          	mov    %eax,0x8(%esp)
80102376:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102379:	89 44 24 04          	mov    %eax,0x4(%esp)
8010237d:	8b 45 08             	mov    0x8(%ebp),%eax
80102380:	89 04 24             	mov    %eax,(%esp)
80102383:	e8 bd fb ff ff       	call   80101f45 <readi>
80102388:	83 f8 10             	cmp    $0x10,%eax
8010238b:	74 0c                	je     80102399 <dirlink+0x79>
      panic("dirlink read");
8010238d:	c7 04 24 5e 8a 10 80 	movl   $0x80108a5e,(%esp)
80102394:	e8 bb e1 ff ff       	call   80100554 <panic>
    if(de.inum == 0)
80102399:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010239c:	66 85 c0             	test   %ax,%ax
8010239f:	75 02                	jne    801023a3 <dirlink+0x83>
      break;
801023a1:	eb 16                	jmp    801023b9 <dirlink+0x99>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801023a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023a6:	83 c0 10             	add    $0x10,%eax
801023a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801023ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
801023af:	8b 45 08             	mov    0x8(%ebp),%eax
801023b2:	8b 40 58             	mov    0x58(%eax),%eax
801023b5:	39 c2                	cmp    %eax,%edx
801023b7:	72 ae                	jb     80102367 <dirlink+0x47>
      panic("dirlink read");
    if(de.inum == 0)
      break;
  }

  strncpy(de.name, name, DIRSIZ);
801023b9:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801023c0:	00 
801023c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801023c4:	89 44 24 04          	mov    %eax,0x4(%esp)
801023c8:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023cb:	83 c0 02             	add    $0x2,%eax
801023ce:	89 04 24             	mov    %eax,(%esp)
801023d1:	e8 fe 2e 00 00       	call   801052d4 <strncpy>
  de.inum = inum;
801023d6:	8b 45 10             	mov    0x10(%ebp),%eax
801023d9:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801023dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023e0:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801023e7:	00 
801023e8:	89 44 24 08          	mov    %eax,0x8(%esp)
801023ec:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023ef:	89 44 24 04          	mov    %eax,0x4(%esp)
801023f3:	8b 45 08             	mov    0x8(%ebp),%eax
801023f6:	89 04 24             	mov    %eax,(%esp)
801023f9:	e8 ab fc ff ff       	call   801020a9 <writei>
801023fe:	83 f8 10             	cmp    $0x10,%eax
80102401:	74 0c                	je     8010240f <dirlink+0xef>
    panic("dirlink");
80102403:	c7 04 24 6b 8a 10 80 	movl   $0x80108a6b,(%esp)
8010240a:	e8 45 e1 ff ff       	call   80100554 <panic>

  return 0;
8010240f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102414:	c9                   	leave  
80102415:	c3                   	ret    

80102416 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102416:	55                   	push   %ebp
80102417:	89 e5                	mov    %esp,%ebp
80102419:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
8010241c:	eb 03                	jmp    80102421 <skipelem+0xb>
    path++;
8010241e:	ff 45 08             	incl   0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102421:	8b 45 08             	mov    0x8(%ebp),%eax
80102424:	8a 00                	mov    (%eax),%al
80102426:	3c 2f                	cmp    $0x2f,%al
80102428:	74 f4                	je     8010241e <skipelem+0x8>
    path++;
  if(*path == 0)
8010242a:	8b 45 08             	mov    0x8(%ebp),%eax
8010242d:	8a 00                	mov    (%eax),%al
8010242f:	84 c0                	test   %al,%al
80102431:	75 0a                	jne    8010243d <skipelem+0x27>
    return 0;
80102433:	b8 00 00 00 00       	mov    $0x0,%eax
80102438:	e9 81 00 00 00       	jmp    801024be <skipelem+0xa8>
  s = path;
8010243d:	8b 45 08             	mov    0x8(%ebp),%eax
80102440:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102443:	eb 03                	jmp    80102448 <skipelem+0x32>
    path++;
80102445:	ff 45 08             	incl   0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80102448:	8b 45 08             	mov    0x8(%ebp),%eax
8010244b:	8a 00                	mov    (%eax),%al
8010244d:	3c 2f                	cmp    $0x2f,%al
8010244f:	74 09                	je     8010245a <skipelem+0x44>
80102451:	8b 45 08             	mov    0x8(%ebp),%eax
80102454:	8a 00                	mov    (%eax),%al
80102456:	84 c0                	test   %al,%al
80102458:	75 eb                	jne    80102445 <skipelem+0x2f>
    path++;
  len = path - s;
8010245a:	8b 55 08             	mov    0x8(%ebp),%edx
8010245d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102460:	29 c2                	sub    %eax,%edx
80102462:	89 d0                	mov    %edx,%eax
80102464:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102467:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
8010246b:	7e 1c                	jle    80102489 <skipelem+0x73>
    memmove(name, s, DIRSIZ);
8010246d:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102474:	00 
80102475:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102478:	89 44 24 04          	mov    %eax,0x4(%esp)
8010247c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010247f:	89 04 24             	mov    %eax,(%esp)
80102482:	e8 60 2d 00 00       	call   801051e7 <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102487:	eb 29                	jmp    801024b2 <skipelem+0x9c>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
80102489:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010248c:	89 44 24 08          	mov    %eax,0x8(%esp)
80102490:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102493:	89 44 24 04          	mov    %eax,0x4(%esp)
80102497:	8b 45 0c             	mov    0xc(%ebp),%eax
8010249a:	89 04 24             	mov    %eax,(%esp)
8010249d:	e8 45 2d 00 00       	call   801051e7 <memmove>
    name[len] = 0;
801024a2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801024a5:	8b 45 0c             	mov    0xc(%ebp),%eax
801024a8:	01 d0                	add    %edx,%eax
801024aa:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801024ad:	eb 03                	jmp    801024b2 <skipelem+0x9c>
    path++;
801024af:	ff 45 08             	incl   0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801024b2:	8b 45 08             	mov    0x8(%ebp),%eax
801024b5:	8a 00                	mov    (%eax),%al
801024b7:	3c 2f                	cmp    $0x2f,%al
801024b9:	74 f4                	je     801024af <skipelem+0x99>
    path++;
  return path;
801024bb:	8b 45 08             	mov    0x8(%ebp),%eax
}
801024be:	c9                   	leave  
801024bf:	c3                   	ret    

801024c0 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801024c0:	55                   	push   %ebp
801024c1:	89 e5                	mov    %esp,%ebp
801024c3:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
801024c6:	8b 45 08             	mov    0x8(%ebp),%eax
801024c9:	8a 00                	mov    (%eax),%al
801024cb:	3c 2f                	cmp    $0x2f,%al
801024cd:	75 1c                	jne    801024eb <namex+0x2b>
    ip = iget(ROOTDEV, ROOTINO);
801024cf:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801024d6:	00 
801024d7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801024de:	e8 c4 f4 ff ff       	call   801019a7 <iget>
801024e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(myproc()->cwd);

  while((path = skipelem(path, name)) != 0){
801024e6:	e9 ac 00 00 00       	jmp    80102597 <namex+0xd7>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
801024eb:	e8 af 1d 00 00       	call   8010429f <myproc>
801024f0:	8b 40 68             	mov    0x68(%eax),%eax
801024f3:	89 04 24             	mov    %eax,(%esp)
801024f6:	e8 81 f5 ff ff       	call   80101a7c <idup>
801024fb:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
801024fe:	e9 94 00 00 00       	jmp    80102597 <namex+0xd7>
    ilock(ip);
80102503:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102506:	89 04 24             	mov    %eax,(%esp)
80102509:	e8 a0 f5 ff ff       	call   80101aae <ilock>
    if(ip->type != T_DIR){
8010250e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102511:	8b 40 50             	mov    0x50(%eax),%eax
80102514:	66 83 f8 01          	cmp    $0x1,%ax
80102518:	74 15                	je     8010252f <namex+0x6f>
      iunlockput(ip);
8010251a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010251d:	89 04 24             	mov    %eax,(%esp)
80102520:	e8 88 f7 ff ff       	call   80101cad <iunlockput>
      return 0;
80102525:	b8 00 00 00 00       	mov    $0x0,%eax
8010252a:	e9 a2 00 00 00       	jmp    801025d1 <namex+0x111>
    }
    if(nameiparent && *path == '\0'){
8010252f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102533:	74 1c                	je     80102551 <namex+0x91>
80102535:	8b 45 08             	mov    0x8(%ebp),%eax
80102538:	8a 00                	mov    (%eax),%al
8010253a:	84 c0                	test   %al,%al
8010253c:	75 13                	jne    80102551 <namex+0x91>
      // Stop one level early.
      iunlock(ip);
8010253e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102541:	89 04 24             	mov    %eax,(%esp)
80102544:	e8 6f f6 ff ff       	call   80101bb8 <iunlock>
      return ip;
80102549:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010254c:	e9 80 00 00 00       	jmp    801025d1 <namex+0x111>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102551:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80102558:	00 
80102559:	8b 45 10             	mov    0x10(%ebp),%eax
8010255c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102560:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102563:	89 04 24             	mov    %eax,(%esp)
80102566:	e8 ef fc ff ff       	call   8010225a <dirlookup>
8010256b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010256e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102572:	75 12                	jne    80102586 <namex+0xc6>
      iunlockput(ip);
80102574:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102577:	89 04 24             	mov    %eax,(%esp)
8010257a:	e8 2e f7 ff ff       	call   80101cad <iunlockput>
      return 0;
8010257f:	b8 00 00 00 00       	mov    $0x0,%eax
80102584:	eb 4b                	jmp    801025d1 <namex+0x111>
    }
    iunlockput(ip);
80102586:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102589:	89 04 24             	mov    %eax,(%esp)
8010258c:	e8 1c f7 ff ff       	call   80101cad <iunlockput>
    ip = next;
80102591:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102594:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);

  while((path = skipelem(path, name)) != 0){
80102597:	8b 45 10             	mov    0x10(%ebp),%eax
8010259a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010259e:	8b 45 08             	mov    0x8(%ebp),%eax
801025a1:	89 04 24             	mov    %eax,(%esp)
801025a4:	e8 6d fe ff ff       	call   80102416 <skipelem>
801025a9:	89 45 08             	mov    %eax,0x8(%ebp)
801025ac:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801025b0:	0f 85 4d ff ff ff    	jne    80102503 <namex+0x43>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
801025b6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801025ba:	74 12                	je     801025ce <namex+0x10e>
    iput(ip);
801025bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025bf:	89 04 24             	mov    %eax,(%esp)
801025c2:	e8 35 f6 ff ff       	call   80101bfc <iput>
    return 0;
801025c7:	b8 00 00 00 00       	mov    $0x0,%eax
801025cc:	eb 03                	jmp    801025d1 <namex+0x111>
  }
  return ip;
801025ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801025d1:	c9                   	leave  
801025d2:	c3                   	ret    

801025d3 <namei>:

struct inode*
namei(char *path)
{
801025d3:	55                   	push   %ebp
801025d4:	89 e5                	mov    %esp,%ebp
801025d6:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
801025d9:	8d 45 ea             	lea    -0x16(%ebp),%eax
801025dc:	89 44 24 08          	mov    %eax,0x8(%esp)
801025e0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801025e7:	00 
801025e8:	8b 45 08             	mov    0x8(%ebp),%eax
801025eb:	89 04 24             	mov    %eax,(%esp)
801025ee:	e8 cd fe ff ff       	call   801024c0 <namex>
}
801025f3:	c9                   	leave  
801025f4:	c3                   	ret    

801025f5 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801025f5:	55                   	push   %ebp
801025f6:	89 e5                	mov    %esp,%ebp
801025f8:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
801025fb:	8b 45 0c             	mov    0xc(%ebp),%eax
801025fe:	89 44 24 08          	mov    %eax,0x8(%esp)
80102602:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102609:	00 
8010260a:	8b 45 08             	mov    0x8(%ebp),%eax
8010260d:	89 04 24             	mov    %eax,(%esp)
80102610:	e8 ab fe ff ff       	call   801024c0 <namex>
}
80102615:	c9                   	leave  
80102616:	c3                   	ret    
	...

80102618 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102618:	55                   	push   %ebp
80102619:	89 e5                	mov    %esp,%ebp
8010261b:	83 ec 14             	sub    $0x14,%esp
8010261e:	8b 45 08             	mov    0x8(%ebp),%eax
80102621:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102625:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102628:	89 c2                	mov    %eax,%edx
8010262a:	ec                   	in     (%dx),%al
8010262b:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010262e:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80102631:	c9                   	leave  
80102632:	c3                   	ret    

80102633 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102633:	55                   	push   %ebp
80102634:	89 e5                	mov    %esp,%ebp
80102636:	57                   	push   %edi
80102637:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102638:	8b 55 08             	mov    0x8(%ebp),%edx
8010263b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010263e:	8b 45 10             	mov    0x10(%ebp),%eax
80102641:	89 cb                	mov    %ecx,%ebx
80102643:	89 df                	mov    %ebx,%edi
80102645:	89 c1                	mov    %eax,%ecx
80102647:	fc                   	cld    
80102648:	f3 6d                	rep insl (%dx),%es:(%edi)
8010264a:	89 c8                	mov    %ecx,%eax
8010264c:	89 fb                	mov    %edi,%ebx
8010264e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102651:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102654:	5b                   	pop    %ebx
80102655:	5f                   	pop    %edi
80102656:	5d                   	pop    %ebp
80102657:	c3                   	ret    

80102658 <outb>:

static inline void
outb(ushort port, uchar data)
{
80102658:	55                   	push   %ebp
80102659:	89 e5                	mov    %esp,%ebp
8010265b:	83 ec 08             	sub    $0x8,%esp
8010265e:	8b 45 08             	mov    0x8(%ebp),%eax
80102661:	8b 55 0c             	mov    0xc(%ebp),%edx
80102664:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102668:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010266b:	8a 45 f8             	mov    -0x8(%ebp),%al
8010266e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80102671:	ee                   	out    %al,(%dx)
}
80102672:	c9                   	leave  
80102673:	c3                   	ret    

80102674 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102674:	55                   	push   %ebp
80102675:	89 e5                	mov    %esp,%ebp
80102677:	56                   	push   %esi
80102678:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102679:	8b 55 08             	mov    0x8(%ebp),%edx
8010267c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010267f:	8b 45 10             	mov    0x10(%ebp),%eax
80102682:	89 cb                	mov    %ecx,%ebx
80102684:	89 de                	mov    %ebx,%esi
80102686:	89 c1                	mov    %eax,%ecx
80102688:	fc                   	cld    
80102689:	f3 6f                	rep outsl %ds:(%esi),(%dx)
8010268b:	89 c8                	mov    %ecx,%eax
8010268d:	89 f3                	mov    %esi,%ebx
8010268f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102692:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102695:	5b                   	pop    %ebx
80102696:	5e                   	pop    %esi
80102697:	5d                   	pop    %ebp
80102698:	c3                   	ret    

80102699 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102699:	55                   	push   %ebp
8010269a:	89 e5                	mov    %esp,%ebp
8010269c:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
8010269f:	90                   	nop
801026a0:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801026a7:	e8 6c ff ff ff       	call   80102618 <inb>
801026ac:	0f b6 c0             	movzbl %al,%eax
801026af:	89 45 fc             	mov    %eax,-0x4(%ebp)
801026b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801026b5:	25 c0 00 00 00       	and    $0xc0,%eax
801026ba:	83 f8 40             	cmp    $0x40,%eax
801026bd:	75 e1                	jne    801026a0 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801026bf:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026c3:	74 11                	je     801026d6 <idewait+0x3d>
801026c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801026c8:	83 e0 21             	and    $0x21,%eax
801026cb:	85 c0                	test   %eax,%eax
801026cd:	74 07                	je     801026d6 <idewait+0x3d>
    return -1;
801026cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801026d4:	eb 05                	jmp    801026db <idewait+0x42>
  return 0;
801026d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801026db:	c9                   	leave  
801026dc:	c3                   	ret    

801026dd <ideinit>:

void
ideinit(void)
{
801026dd:	55                   	push   %ebp
801026de:	89 e5                	mov    %esp,%ebp
801026e0:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
801026e3:	c7 44 24 04 73 8a 10 	movl   $0x80108a73,0x4(%esp)
801026ea:	80 
801026eb:	c7 04 24 80 b8 10 80 	movl   $0x8010b880,(%esp)
801026f2:	e8 a3 27 00 00       	call   80104e9a <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
801026f7:	a1 20 40 11 80       	mov    0x80114020,%eax
801026fc:	48                   	dec    %eax
801026fd:	89 44 24 04          	mov    %eax,0x4(%esp)
80102701:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102708:	e8 66 04 00 00       	call   80102b73 <ioapicenable>
  idewait(0);
8010270d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102714:	e8 80 ff ff ff       	call   80102699 <idewait>

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102719:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
80102720:	00 
80102721:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102728:	e8 2b ff ff ff       	call   80102658 <outb>
  for(i=0; i<1000; i++){
8010272d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102734:	eb 1f                	jmp    80102755 <ideinit+0x78>
    if(inb(0x1f7) != 0){
80102736:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
8010273d:	e8 d6 fe ff ff       	call   80102618 <inb>
80102742:	84 c0                	test   %al,%al
80102744:	74 0c                	je     80102752 <ideinit+0x75>
      havedisk1 = 1;
80102746:	c7 05 b8 b8 10 80 01 	movl   $0x1,0x8010b8b8
8010274d:	00 00 00 
      break;
80102750:	eb 0c                	jmp    8010275e <ideinit+0x81>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102752:	ff 45 f4             	incl   -0xc(%ebp)
80102755:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
8010275c:	7e d8                	jle    80102736 <ideinit+0x59>
      break;
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
8010275e:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
80102765:	00 
80102766:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
8010276d:	e8 e6 fe ff ff       	call   80102658 <outb>
}
80102772:	c9                   	leave  
80102773:	c3                   	ret    

80102774 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102774:	55                   	push   %ebp
80102775:	89 e5                	mov    %esp,%ebp
80102777:	83 ec 28             	sub    $0x28,%esp
  if(b == 0)
8010277a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010277e:	75 0c                	jne    8010278c <idestart+0x18>
    panic("idestart");
80102780:	c7 04 24 77 8a 10 80 	movl   $0x80108a77,(%esp)
80102787:	e8 c8 dd ff ff       	call   80100554 <panic>
  if(b->blockno >= FSSIZE)
8010278c:	8b 45 08             	mov    0x8(%ebp),%eax
8010278f:	8b 40 08             	mov    0x8(%eax),%eax
80102792:	3d e7 03 00 00       	cmp    $0x3e7,%eax
80102797:	76 0c                	jbe    801027a5 <idestart+0x31>
    panic("incorrect blockno");
80102799:	c7 04 24 80 8a 10 80 	movl   $0x80108a80,(%esp)
801027a0:	e8 af dd ff ff       	call   80100554 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
801027a5:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
801027ac:	8b 45 08             	mov    0x8(%ebp),%eax
801027af:	8b 50 08             	mov    0x8(%eax),%edx
801027b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027b5:	0f af c2             	imul   %edx,%eax
801027b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
801027bb:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801027bf:	75 07                	jne    801027c8 <idestart+0x54>
801027c1:	b8 20 00 00 00       	mov    $0x20,%eax
801027c6:	eb 05                	jmp    801027cd <idestart+0x59>
801027c8:	b8 c4 00 00 00       	mov    $0xc4,%eax
801027cd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
801027d0:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801027d4:	75 07                	jne    801027dd <idestart+0x69>
801027d6:	b8 30 00 00 00       	mov    $0x30,%eax
801027db:	eb 05                	jmp    801027e2 <idestart+0x6e>
801027dd:	b8 c5 00 00 00       	mov    $0xc5,%eax
801027e2:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
801027e5:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
801027e9:	7e 0c                	jle    801027f7 <idestart+0x83>
801027eb:	c7 04 24 77 8a 10 80 	movl   $0x80108a77,(%esp)
801027f2:	e8 5d dd ff ff       	call   80100554 <panic>

  idewait(0);
801027f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801027fe:	e8 96 fe ff ff       	call   80102699 <idewait>
  outb(0x3f6, 0);  // generate interrupt
80102803:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010280a:	00 
8010280b:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
80102812:	e8 41 fe ff ff       	call   80102658 <outb>
  outb(0x1f2, sector_per_block);  // number of sectors
80102817:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010281a:	0f b6 c0             	movzbl %al,%eax
8010281d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102821:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
80102828:	e8 2b fe ff ff       	call   80102658 <outb>
  outb(0x1f3, sector & 0xff);
8010282d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102830:	0f b6 c0             	movzbl %al,%eax
80102833:	89 44 24 04          	mov    %eax,0x4(%esp)
80102837:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
8010283e:	e8 15 fe ff ff       	call   80102658 <outb>
  outb(0x1f4, (sector >> 8) & 0xff);
80102843:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102846:	c1 f8 08             	sar    $0x8,%eax
80102849:	0f b6 c0             	movzbl %al,%eax
8010284c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102850:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
80102857:	e8 fc fd ff ff       	call   80102658 <outb>
  outb(0x1f5, (sector >> 16) & 0xff);
8010285c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010285f:	c1 f8 10             	sar    $0x10,%eax
80102862:	0f b6 c0             	movzbl %al,%eax
80102865:	89 44 24 04          	mov    %eax,0x4(%esp)
80102869:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
80102870:	e8 e3 fd ff ff       	call   80102658 <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80102875:	8b 45 08             	mov    0x8(%ebp),%eax
80102878:	8b 40 04             	mov    0x4(%eax),%eax
8010287b:	83 e0 01             	and    $0x1,%eax
8010287e:	c1 e0 04             	shl    $0x4,%eax
80102881:	88 c2                	mov    %al,%dl
80102883:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102886:	c1 f8 18             	sar    $0x18,%eax
80102889:	83 e0 0f             	and    $0xf,%eax
8010288c:	09 d0                	or     %edx,%eax
8010288e:	83 c8 e0             	or     $0xffffffe0,%eax
80102891:	0f b6 c0             	movzbl %al,%eax
80102894:	89 44 24 04          	mov    %eax,0x4(%esp)
80102898:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
8010289f:	e8 b4 fd ff ff       	call   80102658 <outb>
  if(b->flags & B_DIRTY){
801028a4:	8b 45 08             	mov    0x8(%ebp),%eax
801028a7:	8b 00                	mov    (%eax),%eax
801028a9:	83 e0 04             	and    $0x4,%eax
801028ac:	85 c0                	test   %eax,%eax
801028ae:	74 36                	je     801028e6 <idestart+0x172>
    outb(0x1f7, write_cmd);
801028b0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801028b3:	0f b6 c0             	movzbl %al,%eax
801028b6:	89 44 24 04          	mov    %eax,0x4(%esp)
801028ba:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801028c1:	e8 92 fd ff ff       	call   80102658 <outb>
    outsl(0x1f0, b->data, BSIZE/4);
801028c6:	8b 45 08             	mov    0x8(%ebp),%eax
801028c9:	83 c0 5c             	add    $0x5c,%eax
801028cc:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801028d3:	00 
801028d4:	89 44 24 04          	mov    %eax,0x4(%esp)
801028d8:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
801028df:	e8 90 fd ff ff       	call   80102674 <outsl>
801028e4:	eb 16                	jmp    801028fc <idestart+0x188>
  } else {
    outb(0x1f7, read_cmd);
801028e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801028e9:	0f b6 c0             	movzbl %al,%eax
801028ec:	89 44 24 04          	mov    %eax,0x4(%esp)
801028f0:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801028f7:	e8 5c fd ff ff       	call   80102658 <outb>
  }
}
801028fc:	c9                   	leave  
801028fd:	c3                   	ret    

801028fe <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
801028fe:	55                   	push   %ebp
801028ff:	89 e5                	mov    %esp,%ebp
80102901:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102904:	c7 04 24 80 b8 10 80 	movl   $0x8010b880,(%esp)
8010290b:	e8 ab 25 00 00       	call   80104ebb <acquire>

  if((b = idequeue) == 0){
80102910:	a1 b4 b8 10 80       	mov    0x8010b8b4,%eax
80102915:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102918:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010291c:	75 11                	jne    8010292f <ideintr+0x31>
    release(&idelock);
8010291e:	c7 04 24 80 b8 10 80 	movl   $0x8010b880,(%esp)
80102925:	e8 fb 25 00 00       	call   80104f25 <release>
    return;
8010292a:	e9 90 00 00 00       	jmp    801029bf <ideintr+0xc1>
  }
  idequeue = b->qnext;
8010292f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102932:	8b 40 58             	mov    0x58(%eax),%eax
80102935:	a3 b4 b8 10 80       	mov    %eax,0x8010b8b4

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
8010293a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010293d:	8b 00                	mov    (%eax),%eax
8010293f:	83 e0 04             	and    $0x4,%eax
80102942:	85 c0                	test   %eax,%eax
80102944:	75 2e                	jne    80102974 <ideintr+0x76>
80102946:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010294d:	e8 47 fd ff ff       	call   80102699 <idewait>
80102952:	85 c0                	test   %eax,%eax
80102954:	78 1e                	js     80102974 <ideintr+0x76>
    insl(0x1f0, b->data, BSIZE/4);
80102956:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102959:	83 c0 5c             	add    $0x5c,%eax
8010295c:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102963:	00 
80102964:	89 44 24 04          	mov    %eax,0x4(%esp)
80102968:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
8010296f:	e8 bf fc ff ff       	call   80102633 <insl>

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102974:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102977:	8b 00                	mov    (%eax),%eax
80102979:	83 c8 02             	or     $0x2,%eax
8010297c:	89 c2                	mov    %eax,%edx
8010297e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102981:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102983:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102986:	8b 00                	mov    (%eax),%eax
80102988:	83 e0 fb             	and    $0xfffffffb,%eax
8010298b:	89 c2                	mov    %eax,%edx
8010298d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102990:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102992:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102995:	89 04 24             	mov    %eax,(%esp)
80102998:	e8 24 22 00 00       	call   80104bc1 <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
8010299d:	a1 b4 b8 10 80       	mov    0x8010b8b4,%eax
801029a2:	85 c0                	test   %eax,%eax
801029a4:	74 0d                	je     801029b3 <ideintr+0xb5>
    idestart(idequeue);
801029a6:	a1 b4 b8 10 80       	mov    0x8010b8b4,%eax
801029ab:	89 04 24             	mov    %eax,(%esp)
801029ae:	e8 c1 fd ff ff       	call   80102774 <idestart>

  release(&idelock);
801029b3:	c7 04 24 80 b8 10 80 	movl   $0x8010b880,(%esp)
801029ba:	e8 66 25 00 00       	call   80104f25 <release>
}
801029bf:	c9                   	leave  
801029c0:	c3                   	ret    

801029c1 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
801029c1:	55                   	push   %ebp
801029c2:	89 e5                	mov    %esp,%ebp
801029c4:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!holdingsleep(&b->lock))
801029c7:	8b 45 08             	mov    0x8(%ebp),%eax
801029ca:	83 c0 0c             	add    $0xc,%eax
801029cd:	89 04 24             	mov    %eax,(%esp)
801029d0:	e8 5e 24 00 00       	call   80104e33 <holdingsleep>
801029d5:	85 c0                	test   %eax,%eax
801029d7:	75 0c                	jne    801029e5 <iderw+0x24>
    panic("iderw: buf not locked");
801029d9:	c7 04 24 92 8a 10 80 	movl   $0x80108a92,(%esp)
801029e0:	e8 6f db ff ff       	call   80100554 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801029e5:	8b 45 08             	mov    0x8(%ebp),%eax
801029e8:	8b 00                	mov    (%eax),%eax
801029ea:	83 e0 06             	and    $0x6,%eax
801029ed:	83 f8 02             	cmp    $0x2,%eax
801029f0:	75 0c                	jne    801029fe <iderw+0x3d>
    panic("iderw: nothing to do");
801029f2:	c7 04 24 a8 8a 10 80 	movl   $0x80108aa8,(%esp)
801029f9:	e8 56 db ff ff       	call   80100554 <panic>
  if(b->dev != 0 && !havedisk1)
801029fe:	8b 45 08             	mov    0x8(%ebp),%eax
80102a01:	8b 40 04             	mov    0x4(%eax),%eax
80102a04:	85 c0                	test   %eax,%eax
80102a06:	74 15                	je     80102a1d <iderw+0x5c>
80102a08:	a1 b8 b8 10 80       	mov    0x8010b8b8,%eax
80102a0d:	85 c0                	test   %eax,%eax
80102a0f:	75 0c                	jne    80102a1d <iderw+0x5c>
    panic("iderw: ide disk 1 not present");
80102a11:	c7 04 24 bd 8a 10 80 	movl   $0x80108abd,(%esp)
80102a18:	e8 37 db ff ff       	call   80100554 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102a1d:	c7 04 24 80 b8 10 80 	movl   $0x8010b880,(%esp)
80102a24:	e8 92 24 00 00       	call   80104ebb <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102a29:	8b 45 08             	mov    0x8(%ebp),%eax
80102a2c:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102a33:	c7 45 f4 b4 b8 10 80 	movl   $0x8010b8b4,-0xc(%ebp)
80102a3a:	eb 0b                	jmp    80102a47 <iderw+0x86>
80102a3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a3f:	8b 00                	mov    (%eax),%eax
80102a41:	83 c0 58             	add    $0x58,%eax
80102a44:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102a47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a4a:	8b 00                	mov    (%eax),%eax
80102a4c:	85 c0                	test   %eax,%eax
80102a4e:	75 ec                	jne    80102a3c <iderw+0x7b>
    ;
  *pp = b;
80102a50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a53:	8b 55 08             	mov    0x8(%ebp),%edx
80102a56:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
80102a58:	a1 b4 b8 10 80       	mov    0x8010b8b4,%eax
80102a5d:	3b 45 08             	cmp    0x8(%ebp),%eax
80102a60:	75 0d                	jne    80102a6f <iderw+0xae>
    idestart(b);
80102a62:	8b 45 08             	mov    0x8(%ebp),%eax
80102a65:	89 04 24             	mov    %eax,(%esp)
80102a68:	e8 07 fd ff ff       	call   80102774 <idestart>

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a6d:	eb 15                	jmp    80102a84 <iderw+0xc3>
80102a6f:	eb 13                	jmp    80102a84 <iderw+0xc3>
    sleep(b, &idelock);
80102a71:	c7 44 24 04 80 b8 10 	movl   $0x8010b880,0x4(%esp)
80102a78:	80 
80102a79:	8b 45 08             	mov    0x8(%ebp),%eax
80102a7c:	89 04 24             	mov    %eax,(%esp)
80102a7f:	e8 69 20 00 00       	call   80104aed <sleep>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a84:	8b 45 08             	mov    0x8(%ebp),%eax
80102a87:	8b 00                	mov    (%eax),%eax
80102a89:	83 e0 06             	and    $0x6,%eax
80102a8c:	83 f8 02             	cmp    $0x2,%eax
80102a8f:	75 e0                	jne    80102a71 <iderw+0xb0>
    sleep(b, &idelock);
  }


  release(&idelock);
80102a91:	c7 04 24 80 b8 10 80 	movl   $0x8010b880,(%esp)
80102a98:	e8 88 24 00 00       	call   80104f25 <release>
}
80102a9d:	c9                   	leave  
80102a9e:	c3                   	ret    
	...

80102aa0 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102aa0:	55                   	push   %ebp
80102aa1:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102aa3:	a1 54 39 11 80       	mov    0x80113954,%eax
80102aa8:	8b 55 08             	mov    0x8(%ebp),%edx
80102aab:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102aad:	a1 54 39 11 80       	mov    0x80113954,%eax
80102ab2:	8b 40 10             	mov    0x10(%eax),%eax
}
80102ab5:	5d                   	pop    %ebp
80102ab6:	c3                   	ret    

80102ab7 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102ab7:	55                   	push   %ebp
80102ab8:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102aba:	a1 54 39 11 80       	mov    0x80113954,%eax
80102abf:	8b 55 08             	mov    0x8(%ebp),%edx
80102ac2:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102ac4:	a1 54 39 11 80       	mov    0x80113954,%eax
80102ac9:	8b 55 0c             	mov    0xc(%ebp),%edx
80102acc:	89 50 10             	mov    %edx,0x10(%eax)
}
80102acf:	5d                   	pop    %ebp
80102ad0:	c3                   	ret    

80102ad1 <ioapicinit>:

void
ioapicinit(void)
{
80102ad1:	55                   	push   %ebp
80102ad2:	89 e5                	mov    %esp,%ebp
80102ad4:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102ad7:	c7 05 54 39 11 80 00 	movl   $0xfec00000,0x80113954
80102ade:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102ae1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102ae8:	e8 b3 ff ff ff       	call   80102aa0 <ioapicread>
80102aed:	c1 e8 10             	shr    $0x10,%eax
80102af0:	25 ff 00 00 00       	and    $0xff,%eax
80102af5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102af8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102aff:	e8 9c ff ff ff       	call   80102aa0 <ioapicread>
80102b04:	c1 e8 18             	shr    $0x18,%eax
80102b07:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102b0a:	a0 80 3a 11 80       	mov    0x80113a80,%al
80102b0f:	0f b6 c0             	movzbl %al,%eax
80102b12:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102b15:	74 0c                	je     80102b23 <ioapicinit+0x52>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102b17:	c7 04 24 dc 8a 10 80 	movl   $0x80108adc,(%esp)
80102b1e:	e8 9e d8 ff ff       	call   801003c1 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102b23:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102b2a:	eb 3d                	jmp    80102b69 <ioapicinit+0x98>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102b2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b2f:	83 c0 20             	add    $0x20,%eax
80102b32:	0d 00 00 01 00       	or     $0x10000,%eax
80102b37:	89 c2                	mov    %eax,%edx
80102b39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b3c:	83 c0 08             	add    $0x8,%eax
80102b3f:	01 c0                	add    %eax,%eax
80102b41:	89 54 24 04          	mov    %edx,0x4(%esp)
80102b45:	89 04 24             	mov    %eax,(%esp)
80102b48:	e8 6a ff ff ff       	call   80102ab7 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102b4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b50:	83 c0 08             	add    $0x8,%eax
80102b53:	01 c0                	add    %eax,%eax
80102b55:	40                   	inc    %eax
80102b56:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102b5d:	00 
80102b5e:	89 04 24             	mov    %eax,(%esp)
80102b61:	e8 51 ff ff ff       	call   80102ab7 <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102b66:	ff 45 f4             	incl   -0xc(%ebp)
80102b69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b6c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102b6f:	7e bb                	jle    80102b2c <ioapicinit+0x5b>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102b71:	c9                   	leave  
80102b72:	c3                   	ret    

80102b73 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102b73:	55                   	push   %ebp
80102b74:	89 e5                	mov    %esp,%ebp
80102b76:	83 ec 08             	sub    $0x8,%esp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102b79:	8b 45 08             	mov    0x8(%ebp),%eax
80102b7c:	83 c0 20             	add    $0x20,%eax
80102b7f:	89 c2                	mov    %eax,%edx
80102b81:	8b 45 08             	mov    0x8(%ebp),%eax
80102b84:	83 c0 08             	add    $0x8,%eax
80102b87:	01 c0                	add    %eax,%eax
80102b89:	89 54 24 04          	mov    %edx,0x4(%esp)
80102b8d:	89 04 24             	mov    %eax,(%esp)
80102b90:	e8 22 ff ff ff       	call   80102ab7 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102b95:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b98:	c1 e0 18             	shl    $0x18,%eax
80102b9b:	8b 55 08             	mov    0x8(%ebp),%edx
80102b9e:	83 c2 08             	add    $0x8,%edx
80102ba1:	01 d2                	add    %edx,%edx
80102ba3:	42                   	inc    %edx
80102ba4:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ba8:	89 14 24             	mov    %edx,(%esp)
80102bab:	e8 07 ff ff ff       	call   80102ab7 <ioapicwrite>
}
80102bb0:	c9                   	leave  
80102bb1:	c3                   	ret    
	...

80102bb4 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102bb4:	55                   	push   %ebp
80102bb5:	89 e5                	mov    %esp,%ebp
80102bb7:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
80102bba:	c7 44 24 04 0e 8b 10 	movl   $0x80108b0e,0x4(%esp)
80102bc1:	80 
80102bc2:	c7 04 24 60 39 11 80 	movl   $0x80113960,(%esp)
80102bc9:	e8 cc 22 00 00       	call   80104e9a <initlock>
  kmem.use_lock = 0;
80102bce:	c7 05 94 39 11 80 00 	movl   $0x0,0x80113994
80102bd5:	00 00 00 
  freerange(vstart, vend);
80102bd8:	8b 45 0c             	mov    0xc(%ebp),%eax
80102bdb:	89 44 24 04          	mov    %eax,0x4(%esp)
80102bdf:	8b 45 08             	mov    0x8(%ebp),%eax
80102be2:	89 04 24             	mov    %eax,(%esp)
80102be5:	e8 26 00 00 00       	call   80102c10 <freerange>
}
80102bea:	c9                   	leave  
80102beb:	c3                   	ret    

80102bec <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102bec:	55                   	push   %ebp
80102bed:	89 e5                	mov    %esp,%ebp
80102bef:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102bf2:	8b 45 0c             	mov    0xc(%ebp),%eax
80102bf5:	89 44 24 04          	mov    %eax,0x4(%esp)
80102bf9:	8b 45 08             	mov    0x8(%ebp),%eax
80102bfc:	89 04 24             	mov    %eax,(%esp)
80102bff:	e8 0c 00 00 00       	call   80102c10 <freerange>
  kmem.use_lock = 1;
80102c04:	c7 05 94 39 11 80 01 	movl   $0x1,0x80113994
80102c0b:	00 00 00 
}
80102c0e:	c9                   	leave  
80102c0f:	c3                   	ret    

80102c10 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102c10:	55                   	push   %ebp
80102c11:	89 e5                	mov    %esp,%ebp
80102c13:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102c16:	8b 45 08             	mov    0x8(%ebp),%eax
80102c19:	05 ff 0f 00 00       	add    $0xfff,%eax
80102c1e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102c23:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102c26:	eb 12                	jmp    80102c3a <freerange+0x2a>
    kfree(p);
80102c28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c2b:	89 04 24             	mov    %eax,(%esp)
80102c2e:	e8 16 00 00 00       	call   80102c49 <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102c33:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102c3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c3d:	05 00 10 00 00       	add    $0x1000,%eax
80102c42:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102c45:	76 e1                	jbe    80102c28 <freerange+0x18>
    kfree(p);
}
80102c47:	c9                   	leave  
80102c48:	c3                   	ret    

80102c49 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102c49:	55                   	push   %ebp
80102c4a:	89 e5                	mov    %esp,%ebp
80102c4c:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102c4f:	8b 45 08             	mov    0x8(%ebp),%eax
80102c52:	25 ff 0f 00 00       	and    $0xfff,%eax
80102c57:	85 c0                	test   %eax,%eax
80102c59:	75 18                	jne    80102c73 <kfree+0x2a>
80102c5b:	81 7d 08 50 69 11 80 	cmpl   $0x80116950,0x8(%ebp)
80102c62:	72 0f                	jb     80102c73 <kfree+0x2a>
80102c64:	8b 45 08             	mov    0x8(%ebp),%eax
80102c67:	05 00 00 00 80       	add    $0x80000000,%eax
80102c6c:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102c71:	76 0c                	jbe    80102c7f <kfree+0x36>
    panic("kfree");
80102c73:	c7 04 24 13 8b 10 80 	movl   $0x80108b13,(%esp)
80102c7a:	e8 d5 d8 ff ff       	call   80100554 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102c7f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102c86:	00 
80102c87:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102c8e:	00 
80102c8f:	8b 45 08             	mov    0x8(%ebp),%eax
80102c92:	89 04 24             	mov    %eax,(%esp)
80102c95:	e8 84 24 00 00       	call   8010511e <memset>

  if(kmem.use_lock)
80102c9a:	a1 94 39 11 80       	mov    0x80113994,%eax
80102c9f:	85 c0                	test   %eax,%eax
80102ca1:	74 0c                	je     80102caf <kfree+0x66>
    acquire(&kmem.lock);
80102ca3:	c7 04 24 60 39 11 80 	movl   $0x80113960,(%esp)
80102caa:	e8 0c 22 00 00       	call   80104ebb <acquire>
  r = (struct run*)v;
80102caf:	8b 45 08             	mov    0x8(%ebp),%eax
80102cb2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102cb5:	8b 15 98 39 11 80    	mov    0x80113998,%edx
80102cbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cbe:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102cc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cc3:	a3 98 39 11 80       	mov    %eax,0x80113998
  if(kmem.use_lock)
80102cc8:	a1 94 39 11 80       	mov    0x80113994,%eax
80102ccd:	85 c0                	test   %eax,%eax
80102ccf:	74 0c                	je     80102cdd <kfree+0x94>
    release(&kmem.lock);
80102cd1:	c7 04 24 60 39 11 80 	movl   $0x80113960,(%esp)
80102cd8:	e8 48 22 00 00       	call   80104f25 <release>
}
80102cdd:	c9                   	leave  
80102cde:	c3                   	ret    

80102cdf <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102cdf:	55                   	push   %ebp
80102ce0:	89 e5                	mov    %esp,%ebp
80102ce2:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102ce5:	a1 94 39 11 80       	mov    0x80113994,%eax
80102cea:	85 c0                	test   %eax,%eax
80102cec:	74 0c                	je     80102cfa <kalloc+0x1b>
    acquire(&kmem.lock);
80102cee:	c7 04 24 60 39 11 80 	movl   $0x80113960,(%esp)
80102cf5:	e8 c1 21 00 00       	call   80104ebb <acquire>
  r = kmem.freelist;
80102cfa:	a1 98 39 11 80       	mov    0x80113998,%eax
80102cff:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102d02:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102d06:	74 0a                	je     80102d12 <kalloc+0x33>
    kmem.freelist = r->next;
80102d08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d0b:	8b 00                	mov    (%eax),%eax
80102d0d:	a3 98 39 11 80       	mov    %eax,0x80113998
  if(kmem.use_lock)
80102d12:	a1 94 39 11 80       	mov    0x80113994,%eax
80102d17:	85 c0                	test   %eax,%eax
80102d19:	74 0c                	je     80102d27 <kalloc+0x48>
    release(&kmem.lock);
80102d1b:	c7 04 24 60 39 11 80 	movl   $0x80113960,(%esp)
80102d22:	e8 fe 21 00 00       	call   80104f25 <release>
  return (char*)r;
80102d27:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102d2a:	c9                   	leave  
80102d2b:	c3                   	ret    

80102d2c <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102d2c:	55                   	push   %ebp
80102d2d:	89 e5                	mov    %esp,%ebp
80102d2f:	83 ec 14             	sub    $0x14,%esp
80102d32:	8b 45 08             	mov    0x8(%ebp),%eax
80102d35:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d39:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102d3c:	89 c2                	mov    %eax,%edx
80102d3e:	ec                   	in     (%dx),%al
80102d3f:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102d42:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80102d45:	c9                   	leave  
80102d46:	c3                   	ret    

80102d47 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102d47:	55                   	push   %ebp
80102d48:	89 e5                	mov    %esp,%ebp
80102d4a:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102d4d:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102d54:	e8 d3 ff ff ff       	call   80102d2c <inb>
80102d59:	0f b6 c0             	movzbl %al,%eax
80102d5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102d5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d62:	83 e0 01             	and    $0x1,%eax
80102d65:	85 c0                	test   %eax,%eax
80102d67:	75 0a                	jne    80102d73 <kbdgetc+0x2c>
    return -1;
80102d69:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102d6e:	e9 21 01 00 00       	jmp    80102e94 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102d73:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102d7a:	e8 ad ff ff ff       	call   80102d2c <inb>
80102d7f:	0f b6 c0             	movzbl %al,%eax
80102d82:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102d85:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102d8c:	75 17                	jne    80102da5 <kbdgetc+0x5e>
    shift |= E0ESC;
80102d8e:	a1 bc b8 10 80       	mov    0x8010b8bc,%eax
80102d93:	83 c8 40             	or     $0x40,%eax
80102d96:	a3 bc b8 10 80       	mov    %eax,0x8010b8bc
    return 0;
80102d9b:	b8 00 00 00 00       	mov    $0x0,%eax
80102da0:	e9 ef 00 00 00       	jmp    80102e94 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102da5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102da8:	25 80 00 00 00       	and    $0x80,%eax
80102dad:	85 c0                	test   %eax,%eax
80102daf:	74 44                	je     80102df5 <kbdgetc+0xae>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102db1:	a1 bc b8 10 80       	mov    0x8010b8bc,%eax
80102db6:	83 e0 40             	and    $0x40,%eax
80102db9:	85 c0                	test   %eax,%eax
80102dbb:	75 08                	jne    80102dc5 <kbdgetc+0x7e>
80102dbd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dc0:	83 e0 7f             	and    $0x7f,%eax
80102dc3:	eb 03                	jmp    80102dc8 <kbdgetc+0x81>
80102dc5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dc8:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102dcb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dce:	05 20 90 10 80       	add    $0x80109020,%eax
80102dd3:	8a 00                	mov    (%eax),%al
80102dd5:	83 c8 40             	or     $0x40,%eax
80102dd8:	0f b6 c0             	movzbl %al,%eax
80102ddb:	f7 d0                	not    %eax
80102ddd:	89 c2                	mov    %eax,%edx
80102ddf:	a1 bc b8 10 80       	mov    0x8010b8bc,%eax
80102de4:	21 d0                	and    %edx,%eax
80102de6:	a3 bc b8 10 80       	mov    %eax,0x8010b8bc
    return 0;
80102deb:	b8 00 00 00 00       	mov    $0x0,%eax
80102df0:	e9 9f 00 00 00       	jmp    80102e94 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102df5:	a1 bc b8 10 80       	mov    0x8010b8bc,%eax
80102dfa:	83 e0 40             	and    $0x40,%eax
80102dfd:	85 c0                	test   %eax,%eax
80102dff:	74 14                	je     80102e15 <kbdgetc+0xce>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102e01:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102e08:	a1 bc b8 10 80       	mov    0x8010b8bc,%eax
80102e0d:	83 e0 bf             	and    $0xffffffbf,%eax
80102e10:	a3 bc b8 10 80       	mov    %eax,0x8010b8bc
  }

  shift |= shiftcode[data];
80102e15:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e18:	05 20 90 10 80       	add    $0x80109020,%eax
80102e1d:	8a 00                	mov    (%eax),%al
80102e1f:	0f b6 d0             	movzbl %al,%edx
80102e22:	a1 bc b8 10 80       	mov    0x8010b8bc,%eax
80102e27:	09 d0                	or     %edx,%eax
80102e29:	a3 bc b8 10 80       	mov    %eax,0x8010b8bc
  shift ^= togglecode[data];
80102e2e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e31:	05 20 91 10 80       	add    $0x80109120,%eax
80102e36:	8a 00                	mov    (%eax),%al
80102e38:	0f b6 d0             	movzbl %al,%edx
80102e3b:	a1 bc b8 10 80       	mov    0x8010b8bc,%eax
80102e40:	31 d0                	xor    %edx,%eax
80102e42:	a3 bc b8 10 80       	mov    %eax,0x8010b8bc
  c = charcode[shift & (CTL | SHIFT)][data];
80102e47:	a1 bc b8 10 80       	mov    0x8010b8bc,%eax
80102e4c:	83 e0 03             	and    $0x3,%eax
80102e4f:	8b 14 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%edx
80102e56:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e59:	01 d0                	add    %edx,%eax
80102e5b:	8a 00                	mov    (%eax),%al
80102e5d:	0f b6 c0             	movzbl %al,%eax
80102e60:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102e63:	a1 bc b8 10 80       	mov    0x8010b8bc,%eax
80102e68:	83 e0 08             	and    $0x8,%eax
80102e6b:	85 c0                	test   %eax,%eax
80102e6d:	74 22                	je     80102e91 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102e6f:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102e73:	76 0c                	jbe    80102e81 <kbdgetc+0x13a>
80102e75:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102e79:	77 06                	ja     80102e81 <kbdgetc+0x13a>
      c += 'A' - 'a';
80102e7b:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102e7f:	eb 10                	jmp    80102e91 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102e81:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102e85:	76 0a                	jbe    80102e91 <kbdgetc+0x14a>
80102e87:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102e8b:	77 04                	ja     80102e91 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102e8d:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102e91:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102e94:	c9                   	leave  
80102e95:	c3                   	ret    

80102e96 <kbdintr>:

void
kbdintr(void)
{
80102e96:	55                   	push   %ebp
80102e97:	89 e5                	mov    %esp,%ebp
80102e99:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102e9c:	c7 04 24 47 2d 10 80 	movl   $0x80102d47,(%esp)
80102ea3:	e8 4d d9 ff ff       	call   801007f5 <consoleintr>
}
80102ea8:	c9                   	leave  
80102ea9:	c3                   	ret    
	...

80102eac <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102eac:	55                   	push   %ebp
80102ead:	89 e5                	mov    %esp,%ebp
80102eaf:	83 ec 14             	sub    $0x14,%esp
80102eb2:	8b 45 08             	mov    0x8(%ebp),%eax
80102eb5:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102eb9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102ebc:	89 c2                	mov    %eax,%edx
80102ebe:	ec                   	in     (%dx),%al
80102ebf:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102ec2:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80102ec5:	c9                   	leave  
80102ec6:	c3                   	ret    

80102ec7 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102ec7:	55                   	push   %ebp
80102ec8:	89 e5                	mov    %esp,%ebp
80102eca:	83 ec 08             	sub    $0x8,%esp
80102ecd:	8b 45 08             	mov    0x8(%ebp),%eax
80102ed0:	8b 55 0c             	mov    0xc(%ebp),%edx
80102ed3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102ed7:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102eda:	8a 45 f8             	mov    -0x8(%ebp),%al
80102edd:	8b 55 fc             	mov    -0x4(%ebp),%edx
80102ee0:	ee                   	out    %al,(%dx)
}
80102ee1:	c9                   	leave  
80102ee2:	c3                   	ret    

80102ee3 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102ee3:	55                   	push   %ebp
80102ee4:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102ee6:	a1 9c 39 11 80       	mov    0x8011399c,%eax
80102eeb:	8b 55 08             	mov    0x8(%ebp),%edx
80102eee:	c1 e2 02             	shl    $0x2,%edx
80102ef1:	01 c2                	add    %eax,%edx
80102ef3:	8b 45 0c             	mov    0xc(%ebp),%eax
80102ef6:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102ef8:	a1 9c 39 11 80       	mov    0x8011399c,%eax
80102efd:	83 c0 20             	add    $0x20,%eax
80102f00:	8b 00                	mov    (%eax),%eax
}
80102f02:	5d                   	pop    %ebp
80102f03:	c3                   	ret    

80102f04 <lapicinit>:

void
lapicinit(void)
{
80102f04:	55                   	push   %ebp
80102f05:	89 e5                	mov    %esp,%ebp
80102f07:	83 ec 08             	sub    $0x8,%esp
  if(!lapic)
80102f0a:	a1 9c 39 11 80       	mov    0x8011399c,%eax
80102f0f:	85 c0                	test   %eax,%eax
80102f11:	75 05                	jne    80102f18 <lapicinit+0x14>
    return;
80102f13:	e9 43 01 00 00       	jmp    8010305b <lapicinit+0x157>

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102f18:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80102f1f:	00 
80102f20:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80102f27:	e8 b7 ff ff ff       	call   80102ee3 <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102f2c:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
80102f33:	00 
80102f34:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80102f3b:	e8 a3 ff ff ff       	call   80102ee3 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102f40:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80102f47:	00 
80102f48:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102f4f:	e8 8f ff ff ff       	call   80102ee3 <lapicw>
  lapicw(TICR, 10000000);
80102f54:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80102f5b:	00 
80102f5c:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
80102f63:	e8 7b ff ff ff       	call   80102ee3 <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102f68:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102f6f:	00 
80102f70:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
80102f77:	e8 67 ff ff ff       	call   80102ee3 <lapicw>
  lapicw(LINT1, MASKED);
80102f7c:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102f83:	00 
80102f84:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80102f8b:	e8 53 ff ff ff       	call   80102ee3 <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102f90:	a1 9c 39 11 80       	mov    0x8011399c,%eax
80102f95:	83 c0 30             	add    $0x30,%eax
80102f98:	8b 00                	mov    (%eax),%eax
80102f9a:	c1 e8 10             	shr    $0x10,%eax
80102f9d:	0f b6 c0             	movzbl %al,%eax
80102fa0:	83 f8 03             	cmp    $0x3,%eax
80102fa3:	76 14                	jbe    80102fb9 <lapicinit+0xb5>
    lapicw(PCINT, MASKED);
80102fa5:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102fac:	00 
80102fad:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80102fb4:	e8 2a ff ff ff       	call   80102ee3 <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102fb9:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80102fc0:	00 
80102fc1:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80102fc8:	e8 16 ff ff ff       	call   80102ee3 <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102fcd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102fd4:	00 
80102fd5:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102fdc:	e8 02 ff ff ff       	call   80102ee3 <lapicw>
  lapicw(ESR, 0);
80102fe1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102fe8:	00 
80102fe9:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102ff0:	e8 ee fe ff ff       	call   80102ee3 <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102ff5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102ffc:	00 
80102ffd:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80103004:	e8 da fe ff ff       	call   80102ee3 <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80103009:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103010:	00 
80103011:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103018:	e8 c6 fe ff ff       	call   80102ee3 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
8010301d:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
80103024:	00 
80103025:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
8010302c:	e8 b2 fe ff ff       	call   80102ee3 <lapicw>
  while(lapic[ICRLO] & DELIVS)
80103031:	90                   	nop
80103032:	a1 9c 39 11 80       	mov    0x8011399c,%eax
80103037:	05 00 03 00 00       	add    $0x300,%eax
8010303c:	8b 00                	mov    (%eax),%eax
8010303e:	25 00 10 00 00       	and    $0x1000,%eax
80103043:	85 c0                	test   %eax,%eax
80103045:	75 eb                	jne    80103032 <lapicinit+0x12e>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80103047:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010304e:	00 
8010304f:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103056:	e8 88 fe ff ff       	call   80102ee3 <lapicw>
}
8010305b:	c9                   	leave  
8010305c:	c3                   	ret    

8010305d <lapicid>:

int
lapicid(void)
{
8010305d:	55                   	push   %ebp
8010305e:	89 e5                	mov    %esp,%ebp
  if (!lapic)
80103060:	a1 9c 39 11 80       	mov    0x8011399c,%eax
80103065:	85 c0                	test   %eax,%eax
80103067:	75 07                	jne    80103070 <lapicid+0x13>
    return 0;
80103069:	b8 00 00 00 00       	mov    $0x0,%eax
8010306e:	eb 0d                	jmp    8010307d <lapicid+0x20>
  return lapic[ID] >> 24;
80103070:	a1 9c 39 11 80       	mov    0x8011399c,%eax
80103075:	83 c0 20             	add    $0x20,%eax
80103078:	8b 00                	mov    (%eax),%eax
8010307a:	c1 e8 18             	shr    $0x18,%eax
}
8010307d:	5d                   	pop    %ebp
8010307e:	c3                   	ret    

8010307f <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
8010307f:	55                   	push   %ebp
80103080:	89 e5                	mov    %esp,%ebp
80103082:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
80103085:	a1 9c 39 11 80       	mov    0x8011399c,%eax
8010308a:	85 c0                	test   %eax,%eax
8010308c:	74 14                	je     801030a2 <lapiceoi+0x23>
    lapicw(EOI, 0);
8010308e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103095:	00 
80103096:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
8010309d:	e8 41 fe ff ff       	call   80102ee3 <lapicw>
}
801030a2:	c9                   	leave  
801030a3:	c3                   	ret    

801030a4 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
801030a4:	55                   	push   %ebp
801030a5:	89 e5                	mov    %esp,%ebp
}
801030a7:	5d                   	pop    %ebp
801030a8:	c3                   	ret    

801030a9 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
801030a9:	55                   	push   %ebp
801030aa:	89 e5                	mov    %esp,%ebp
801030ac:	83 ec 1c             	sub    $0x1c,%esp
801030af:	8b 45 08             	mov    0x8(%ebp),%eax
801030b2:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
801030b5:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
801030bc:	00 
801030bd:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
801030c4:	e8 fe fd ff ff       	call   80102ec7 <outb>
  outb(CMOS_PORT+1, 0x0A);
801030c9:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
801030d0:	00 
801030d1:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
801030d8:	e8 ea fd ff ff       	call   80102ec7 <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
801030dd:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
801030e4:	8b 45 f8             	mov    -0x8(%ebp),%eax
801030e7:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
801030ec:	8b 45 f8             	mov    -0x8(%ebp),%eax
801030ef:	8d 50 02             	lea    0x2(%eax),%edx
801030f2:	8b 45 0c             	mov    0xc(%ebp),%eax
801030f5:	c1 e8 04             	shr    $0x4,%eax
801030f8:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
801030fb:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801030ff:	c1 e0 18             	shl    $0x18,%eax
80103102:	89 44 24 04          	mov    %eax,0x4(%esp)
80103106:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
8010310d:	e8 d1 fd ff ff       	call   80102ee3 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80103112:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
80103119:	00 
8010311a:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103121:	e8 bd fd ff ff       	call   80102ee3 <lapicw>
  microdelay(200);
80103126:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
8010312d:	e8 72 ff ff ff       	call   801030a4 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
80103132:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
80103139:	00 
8010313a:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103141:	e8 9d fd ff ff       	call   80102ee3 <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80103146:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
8010314d:	e8 52 ff ff ff       	call   801030a4 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103152:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103159:	eb 3f                	jmp    8010319a <lapicstartap+0xf1>
    lapicw(ICRHI, apicid<<24);
8010315b:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010315f:	c1 e0 18             	shl    $0x18,%eax
80103162:	89 44 24 04          	mov    %eax,0x4(%esp)
80103166:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
8010316d:	e8 71 fd ff ff       	call   80102ee3 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80103172:	8b 45 0c             	mov    0xc(%ebp),%eax
80103175:	c1 e8 0c             	shr    $0xc,%eax
80103178:	80 cc 06             	or     $0x6,%ah
8010317b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010317f:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103186:	e8 58 fd ff ff       	call   80102ee3 <lapicw>
    microdelay(200);
8010318b:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103192:	e8 0d ff ff ff       	call   801030a4 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103197:	ff 45 fc             	incl   -0x4(%ebp)
8010319a:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
8010319e:	7e bb                	jle    8010315b <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
801031a0:	c9                   	leave  
801031a1:	c3                   	ret    

801031a2 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
801031a2:	55                   	push   %ebp
801031a3:	89 e5                	mov    %esp,%ebp
801031a5:	83 ec 08             	sub    $0x8,%esp
  outb(CMOS_PORT,  reg);
801031a8:	8b 45 08             	mov    0x8(%ebp),%eax
801031ab:	0f b6 c0             	movzbl %al,%eax
801031ae:	89 44 24 04          	mov    %eax,0x4(%esp)
801031b2:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
801031b9:	e8 09 fd ff ff       	call   80102ec7 <outb>
  microdelay(200);
801031be:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801031c5:	e8 da fe ff ff       	call   801030a4 <microdelay>

  return inb(CMOS_RETURN);
801031ca:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
801031d1:	e8 d6 fc ff ff       	call   80102eac <inb>
801031d6:	0f b6 c0             	movzbl %al,%eax
}
801031d9:	c9                   	leave  
801031da:	c3                   	ret    

801031db <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
801031db:	55                   	push   %ebp
801031dc:	89 e5                	mov    %esp,%ebp
801031de:	83 ec 04             	sub    $0x4,%esp
  r->second = cmos_read(SECS);
801031e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801031e8:	e8 b5 ff ff ff       	call   801031a2 <cmos_read>
801031ed:	8b 55 08             	mov    0x8(%ebp),%edx
801031f0:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
801031f2:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801031f9:	e8 a4 ff ff ff       	call   801031a2 <cmos_read>
801031fe:	8b 55 08             	mov    0x8(%ebp),%edx
80103201:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80103204:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
8010320b:	e8 92 ff ff ff       	call   801031a2 <cmos_read>
80103210:	8b 55 08             	mov    0x8(%ebp),%edx
80103213:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80103216:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
8010321d:	e8 80 ff ff ff       	call   801031a2 <cmos_read>
80103222:	8b 55 08             	mov    0x8(%ebp),%edx
80103225:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80103228:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010322f:	e8 6e ff ff ff       	call   801031a2 <cmos_read>
80103234:	8b 55 08             	mov    0x8(%ebp),%edx
80103237:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
8010323a:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
80103241:	e8 5c ff ff ff       	call   801031a2 <cmos_read>
80103246:	8b 55 08             	mov    0x8(%ebp),%edx
80103249:	89 42 14             	mov    %eax,0x14(%edx)
}
8010324c:	c9                   	leave  
8010324d:	c3                   	ret    

8010324e <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
8010324e:	55                   	push   %ebp
8010324f:	89 e5                	mov    %esp,%ebp
80103251:	57                   	push   %edi
80103252:	56                   	push   %esi
80103253:	53                   	push   %ebx
80103254:	83 ec 5c             	sub    $0x5c,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80103257:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
8010325e:	e8 3f ff ff ff       	call   801031a2 <cmos_read>
80103263:	89 45 e4             	mov    %eax,-0x1c(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80103266:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103269:	83 e0 04             	and    $0x4,%eax
8010326c:	85 c0                	test   %eax,%eax
8010326e:	0f 94 c0             	sete   %al
80103271:	0f b6 c0             	movzbl %al,%eax
80103274:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80103277:	8d 45 c8             	lea    -0x38(%ebp),%eax
8010327a:	89 04 24             	mov    %eax,(%esp)
8010327d:	e8 59 ff ff ff       	call   801031db <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80103282:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80103289:	e8 14 ff ff ff       	call   801031a2 <cmos_read>
8010328e:	25 80 00 00 00       	and    $0x80,%eax
80103293:	85 c0                	test   %eax,%eax
80103295:	74 02                	je     80103299 <cmostime+0x4b>
        continue;
80103297:	eb 36                	jmp    801032cf <cmostime+0x81>
    fill_rtcdate(&t2);
80103299:	8d 45 b0             	lea    -0x50(%ebp),%eax
8010329c:	89 04 24             	mov    %eax,(%esp)
8010329f:	e8 37 ff ff ff       	call   801031db <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
801032a4:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
801032ab:	00 
801032ac:	8d 45 b0             	lea    -0x50(%ebp),%eax
801032af:	89 44 24 04          	mov    %eax,0x4(%esp)
801032b3:	8d 45 c8             	lea    -0x38(%ebp),%eax
801032b6:	89 04 24             	mov    %eax,(%esp)
801032b9:	e8 d7 1e 00 00       	call   80105195 <memcmp>
801032be:	85 c0                	test   %eax,%eax
801032c0:	75 0d                	jne    801032cf <cmostime+0x81>
      break;
801032c2:	90                   	nop
  }

  // convert
  if(bcd) {
801032c3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801032c7:	0f 84 ac 00 00 00    	je     80103379 <cmostime+0x12b>
801032cd:	eb 02                	jmp    801032d1 <cmostime+0x83>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
801032cf:	eb a6                	jmp    80103277 <cmostime+0x29>

  // convert
  if(bcd) {
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801032d1:	8b 45 c8             	mov    -0x38(%ebp),%eax
801032d4:	c1 e8 04             	shr    $0x4,%eax
801032d7:	89 c2                	mov    %eax,%edx
801032d9:	89 d0                	mov    %edx,%eax
801032db:	c1 e0 02             	shl    $0x2,%eax
801032de:	01 d0                	add    %edx,%eax
801032e0:	01 c0                	add    %eax,%eax
801032e2:	8b 55 c8             	mov    -0x38(%ebp),%edx
801032e5:	83 e2 0f             	and    $0xf,%edx
801032e8:	01 d0                	add    %edx,%eax
801032ea:	89 45 c8             	mov    %eax,-0x38(%ebp)
    CONV(minute);
801032ed:	8b 45 cc             	mov    -0x34(%ebp),%eax
801032f0:	c1 e8 04             	shr    $0x4,%eax
801032f3:	89 c2                	mov    %eax,%edx
801032f5:	89 d0                	mov    %edx,%eax
801032f7:	c1 e0 02             	shl    $0x2,%eax
801032fa:	01 d0                	add    %edx,%eax
801032fc:	01 c0                	add    %eax,%eax
801032fe:	8b 55 cc             	mov    -0x34(%ebp),%edx
80103301:	83 e2 0f             	and    $0xf,%edx
80103304:	01 d0                	add    %edx,%eax
80103306:	89 45 cc             	mov    %eax,-0x34(%ebp)
    CONV(hour  );
80103309:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010330c:	c1 e8 04             	shr    $0x4,%eax
8010330f:	89 c2                	mov    %eax,%edx
80103311:	89 d0                	mov    %edx,%eax
80103313:	c1 e0 02             	shl    $0x2,%eax
80103316:	01 d0                	add    %edx,%eax
80103318:	01 c0                	add    %eax,%eax
8010331a:	8b 55 d0             	mov    -0x30(%ebp),%edx
8010331d:	83 e2 0f             	and    $0xf,%edx
80103320:	01 d0                	add    %edx,%eax
80103322:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(day   );
80103325:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80103328:	c1 e8 04             	shr    $0x4,%eax
8010332b:	89 c2                	mov    %eax,%edx
8010332d:	89 d0                	mov    %edx,%eax
8010332f:	c1 e0 02             	shl    $0x2,%eax
80103332:	01 d0                	add    %edx,%eax
80103334:	01 c0                	add    %eax,%eax
80103336:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80103339:	83 e2 0f             	and    $0xf,%edx
8010333c:	01 d0                	add    %edx,%eax
8010333e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(month );
80103341:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103344:	c1 e8 04             	shr    $0x4,%eax
80103347:	89 c2                	mov    %eax,%edx
80103349:	89 d0                	mov    %edx,%eax
8010334b:	c1 e0 02             	shl    $0x2,%eax
8010334e:	01 d0                	add    %edx,%eax
80103350:	01 c0                	add    %eax,%eax
80103352:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103355:	83 e2 0f             	and    $0xf,%edx
80103358:	01 d0                	add    %edx,%eax
8010335a:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(year  );
8010335d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103360:	c1 e8 04             	shr    $0x4,%eax
80103363:	89 c2                	mov    %eax,%edx
80103365:	89 d0                	mov    %edx,%eax
80103367:	c1 e0 02             	shl    $0x2,%eax
8010336a:	01 d0                	add    %edx,%eax
8010336c:	01 c0                	add    %eax,%eax
8010336e:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103371:	83 e2 0f             	and    $0xf,%edx
80103374:	01 d0                	add    %edx,%eax
80103376:	89 45 dc             	mov    %eax,-0x24(%ebp)
#undef     CONV
  }

  *r = t1;
80103379:	8b 45 08             	mov    0x8(%ebp),%eax
8010337c:	89 c2                	mov    %eax,%edx
8010337e:	8d 5d c8             	lea    -0x38(%ebp),%ebx
80103381:	b8 06 00 00 00       	mov    $0x6,%eax
80103386:	89 d7                	mov    %edx,%edi
80103388:	89 de                	mov    %ebx,%esi
8010338a:	89 c1                	mov    %eax,%ecx
8010338c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  r->year += 2000;
8010338e:	8b 45 08             	mov    0x8(%ebp),%eax
80103391:	8b 40 14             	mov    0x14(%eax),%eax
80103394:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
8010339a:	8b 45 08             	mov    0x8(%ebp),%eax
8010339d:	89 50 14             	mov    %edx,0x14(%eax)
}
801033a0:	83 c4 5c             	add    $0x5c,%esp
801033a3:	5b                   	pop    %ebx
801033a4:	5e                   	pop    %esi
801033a5:	5f                   	pop    %edi
801033a6:	5d                   	pop    %ebp
801033a7:	c3                   	ret    

801033a8 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
801033a8:	55                   	push   %ebp
801033a9:	89 e5                	mov    %esp,%ebp
801033ab:	83 ec 38             	sub    $0x38,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
801033ae:	c7 44 24 04 19 8b 10 	movl   $0x80108b19,0x4(%esp)
801033b5:	80 
801033b6:	c7 04 24 a0 39 11 80 	movl   $0x801139a0,(%esp)
801033bd:	e8 d8 1a 00 00       	call   80104e9a <initlock>
  readsb(dev, &sb);
801033c2:	8d 45 dc             	lea    -0x24(%ebp),%eax
801033c5:	89 44 24 04          	mov    %eax,0x4(%esp)
801033c9:	8b 45 08             	mov    0x8(%ebp),%eax
801033cc:	89 04 24             	mov    %eax,(%esp)
801033cf:	e8 d8 e0 ff ff       	call   801014ac <readsb>
  log.start = sb.logstart;
801033d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033d7:	a3 d4 39 11 80       	mov    %eax,0x801139d4
  log.size = sb.nlog;
801033dc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801033df:	a3 d8 39 11 80       	mov    %eax,0x801139d8
  log.dev = dev;
801033e4:	8b 45 08             	mov    0x8(%ebp),%eax
801033e7:	a3 e4 39 11 80       	mov    %eax,0x801139e4
  recover_from_log();
801033ec:	e8 95 01 00 00       	call   80103586 <recover_from_log>
}
801033f1:	c9                   	leave  
801033f2:	c3                   	ret    

801033f3 <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
801033f3:	55                   	push   %ebp
801033f4:	89 e5                	mov    %esp,%ebp
801033f6:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801033f9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103400:	e9 89 00 00 00       	jmp    8010348e <install_trans+0x9b>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103405:	8b 15 d4 39 11 80    	mov    0x801139d4,%edx
8010340b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010340e:	01 d0                	add    %edx,%eax
80103410:	40                   	inc    %eax
80103411:	89 c2                	mov    %eax,%edx
80103413:	a1 e4 39 11 80       	mov    0x801139e4,%eax
80103418:	89 54 24 04          	mov    %edx,0x4(%esp)
8010341c:	89 04 24             	mov    %eax,(%esp)
8010341f:	e8 91 cd ff ff       	call   801001b5 <bread>
80103424:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103427:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010342a:	83 c0 10             	add    $0x10,%eax
8010342d:	8b 04 85 ac 39 11 80 	mov    -0x7feec654(,%eax,4),%eax
80103434:	89 c2                	mov    %eax,%edx
80103436:	a1 e4 39 11 80       	mov    0x801139e4,%eax
8010343b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010343f:	89 04 24             	mov    %eax,(%esp)
80103442:	e8 6e cd ff ff       	call   801001b5 <bread>
80103447:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
8010344a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010344d:	8d 50 5c             	lea    0x5c(%eax),%edx
80103450:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103453:	83 c0 5c             	add    $0x5c,%eax
80103456:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010345d:	00 
8010345e:	89 54 24 04          	mov    %edx,0x4(%esp)
80103462:	89 04 24             	mov    %eax,(%esp)
80103465:	e8 7d 1d 00 00       	call   801051e7 <memmove>
    bwrite(dbuf);  // write dst to disk
8010346a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010346d:	89 04 24             	mov    %eax,(%esp)
80103470:	e8 77 cd ff ff       	call   801001ec <bwrite>
    brelse(lbuf);
80103475:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103478:	89 04 24             	mov    %eax,(%esp)
8010347b:	e8 ac cd ff ff       	call   8010022c <brelse>
    brelse(dbuf);
80103480:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103483:	89 04 24             	mov    %eax,(%esp)
80103486:	e8 a1 cd ff ff       	call   8010022c <brelse>
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010348b:	ff 45 f4             	incl   -0xc(%ebp)
8010348e:	a1 e8 39 11 80       	mov    0x801139e8,%eax
80103493:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103496:	0f 8f 69 ff ff ff    	jg     80103405 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf);
    brelse(dbuf);
  }
}
8010349c:	c9                   	leave  
8010349d:	c3                   	ret    

8010349e <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
8010349e:	55                   	push   %ebp
8010349f:	89 e5                	mov    %esp,%ebp
801034a1:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
801034a4:	a1 d4 39 11 80       	mov    0x801139d4,%eax
801034a9:	89 c2                	mov    %eax,%edx
801034ab:	a1 e4 39 11 80       	mov    0x801139e4,%eax
801034b0:	89 54 24 04          	mov    %edx,0x4(%esp)
801034b4:	89 04 24             	mov    %eax,(%esp)
801034b7:	e8 f9 cc ff ff       	call   801001b5 <bread>
801034bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
801034bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034c2:	83 c0 5c             	add    $0x5c,%eax
801034c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
801034c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034cb:	8b 00                	mov    (%eax),%eax
801034cd:	a3 e8 39 11 80       	mov    %eax,0x801139e8
  for (i = 0; i < log.lh.n; i++) {
801034d2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801034d9:	eb 1a                	jmp    801034f5 <read_head+0x57>
    log.lh.block[i] = lh->block[i];
801034db:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034de:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034e1:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
801034e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034e8:	83 c2 10             	add    $0x10,%edx
801034eb:	89 04 95 ac 39 11 80 	mov    %eax,-0x7feec654(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
801034f2:	ff 45 f4             	incl   -0xc(%ebp)
801034f5:	a1 e8 39 11 80       	mov    0x801139e8,%eax
801034fa:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801034fd:	7f dc                	jg     801034db <read_head+0x3d>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
801034ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103502:	89 04 24             	mov    %eax,(%esp)
80103505:	e8 22 cd ff ff       	call   8010022c <brelse>
}
8010350a:	c9                   	leave  
8010350b:	c3                   	ret    

8010350c <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
8010350c:	55                   	push   %ebp
8010350d:	89 e5                	mov    %esp,%ebp
8010350f:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103512:	a1 d4 39 11 80       	mov    0x801139d4,%eax
80103517:	89 c2                	mov    %eax,%edx
80103519:	a1 e4 39 11 80       	mov    0x801139e4,%eax
8010351e:	89 54 24 04          	mov    %edx,0x4(%esp)
80103522:	89 04 24             	mov    %eax,(%esp)
80103525:	e8 8b cc ff ff       	call   801001b5 <bread>
8010352a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
8010352d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103530:	83 c0 5c             	add    $0x5c,%eax
80103533:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103536:	8b 15 e8 39 11 80    	mov    0x801139e8,%edx
8010353c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010353f:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103541:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103548:	eb 1a                	jmp    80103564 <write_head+0x58>
    hb->block[i] = log.lh.block[i];
8010354a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010354d:	83 c0 10             	add    $0x10,%eax
80103550:	8b 0c 85 ac 39 11 80 	mov    -0x7feec654(,%eax,4),%ecx
80103557:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010355a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010355d:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80103561:	ff 45 f4             	incl   -0xc(%ebp)
80103564:	a1 e8 39 11 80       	mov    0x801139e8,%eax
80103569:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010356c:	7f dc                	jg     8010354a <write_head+0x3e>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
8010356e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103571:	89 04 24             	mov    %eax,(%esp)
80103574:	e8 73 cc ff ff       	call   801001ec <bwrite>
  brelse(buf);
80103579:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010357c:	89 04 24             	mov    %eax,(%esp)
8010357f:	e8 a8 cc ff ff       	call   8010022c <brelse>
}
80103584:	c9                   	leave  
80103585:	c3                   	ret    

80103586 <recover_from_log>:

static void
recover_from_log(void)
{
80103586:	55                   	push   %ebp
80103587:	89 e5                	mov    %esp,%ebp
80103589:	83 ec 08             	sub    $0x8,%esp
  read_head();
8010358c:	e8 0d ff ff ff       	call   8010349e <read_head>
  install_trans(); // if committed, copy from log to disk
80103591:	e8 5d fe ff ff       	call   801033f3 <install_trans>
  log.lh.n = 0;
80103596:	c7 05 e8 39 11 80 00 	movl   $0x0,0x801139e8
8010359d:	00 00 00 
  write_head(); // clear the log
801035a0:	e8 67 ff ff ff       	call   8010350c <write_head>
}
801035a5:	c9                   	leave  
801035a6:	c3                   	ret    

801035a7 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
801035a7:	55                   	push   %ebp
801035a8:	89 e5                	mov    %esp,%ebp
801035aa:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
801035ad:	c7 04 24 a0 39 11 80 	movl   $0x801139a0,(%esp)
801035b4:	e8 02 19 00 00       	call   80104ebb <acquire>
  while(1){
    if(log.committing){
801035b9:	a1 e0 39 11 80       	mov    0x801139e0,%eax
801035be:	85 c0                	test   %eax,%eax
801035c0:	74 16                	je     801035d8 <begin_op+0x31>
      sleep(&log, &log.lock);
801035c2:	c7 44 24 04 a0 39 11 	movl   $0x801139a0,0x4(%esp)
801035c9:	80 
801035ca:	c7 04 24 a0 39 11 80 	movl   $0x801139a0,(%esp)
801035d1:	e8 17 15 00 00       	call   80104aed <sleep>
801035d6:	eb 4d                	jmp    80103625 <begin_op+0x7e>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801035d8:	8b 15 e8 39 11 80    	mov    0x801139e8,%edx
801035de:	a1 dc 39 11 80       	mov    0x801139dc,%eax
801035e3:	8d 48 01             	lea    0x1(%eax),%ecx
801035e6:	89 c8                	mov    %ecx,%eax
801035e8:	c1 e0 02             	shl    $0x2,%eax
801035eb:	01 c8                	add    %ecx,%eax
801035ed:	01 c0                	add    %eax,%eax
801035ef:	01 d0                	add    %edx,%eax
801035f1:	83 f8 1e             	cmp    $0x1e,%eax
801035f4:	7e 16                	jle    8010360c <begin_op+0x65>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801035f6:	c7 44 24 04 a0 39 11 	movl   $0x801139a0,0x4(%esp)
801035fd:	80 
801035fe:	c7 04 24 a0 39 11 80 	movl   $0x801139a0,(%esp)
80103605:	e8 e3 14 00 00       	call   80104aed <sleep>
8010360a:	eb 19                	jmp    80103625 <begin_op+0x7e>
    } else {
      log.outstanding += 1;
8010360c:	a1 dc 39 11 80       	mov    0x801139dc,%eax
80103611:	40                   	inc    %eax
80103612:	a3 dc 39 11 80       	mov    %eax,0x801139dc
      release(&log.lock);
80103617:	c7 04 24 a0 39 11 80 	movl   $0x801139a0,(%esp)
8010361e:	e8 02 19 00 00       	call   80104f25 <release>
      break;
80103623:	eb 02                	jmp    80103627 <begin_op+0x80>
    }
  }
80103625:	eb 92                	jmp    801035b9 <begin_op+0x12>
}
80103627:	c9                   	leave  
80103628:	c3                   	ret    

80103629 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103629:	55                   	push   %ebp
8010362a:	89 e5                	mov    %esp,%ebp
8010362c:	83 ec 28             	sub    $0x28,%esp
  int do_commit = 0;
8010362f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103636:	c7 04 24 a0 39 11 80 	movl   $0x801139a0,(%esp)
8010363d:	e8 79 18 00 00       	call   80104ebb <acquire>
  log.outstanding -= 1;
80103642:	a1 dc 39 11 80       	mov    0x801139dc,%eax
80103647:	48                   	dec    %eax
80103648:	a3 dc 39 11 80       	mov    %eax,0x801139dc
  if(log.committing)
8010364d:	a1 e0 39 11 80       	mov    0x801139e0,%eax
80103652:	85 c0                	test   %eax,%eax
80103654:	74 0c                	je     80103662 <end_op+0x39>
    panic("log.committing");
80103656:	c7 04 24 1d 8b 10 80 	movl   $0x80108b1d,(%esp)
8010365d:	e8 f2 ce ff ff       	call   80100554 <panic>
  if(log.outstanding == 0){
80103662:	a1 dc 39 11 80       	mov    0x801139dc,%eax
80103667:	85 c0                	test   %eax,%eax
80103669:	75 13                	jne    8010367e <end_op+0x55>
    do_commit = 1;
8010366b:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103672:	c7 05 e0 39 11 80 01 	movl   $0x1,0x801139e0
80103679:	00 00 00 
8010367c:	eb 0c                	jmp    8010368a <end_op+0x61>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
8010367e:	c7 04 24 a0 39 11 80 	movl   $0x801139a0,(%esp)
80103685:	e8 37 15 00 00       	call   80104bc1 <wakeup>
  }
  release(&log.lock);
8010368a:	c7 04 24 a0 39 11 80 	movl   $0x801139a0,(%esp)
80103691:	e8 8f 18 00 00       	call   80104f25 <release>

  if(do_commit){
80103696:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010369a:	74 33                	je     801036cf <end_op+0xa6>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
8010369c:	e8 db 00 00 00       	call   8010377c <commit>
    acquire(&log.lock);
801036a1:	c7 04 24 a0 39 11 80 	movl   $0x801139a0,(%esp)
801036a8:	e8 0e 18 00 00       	call   80104ebb <acquire>
    log.committing = 0;
801036ad:	c7 05 e0 39 11 80 00 	movl   $0x0,0x801139e0
801036b4:	00 00 00 
    wakeup(&log);
801036b7:	c7 04 24 a0 39 11 80 	movl   $0x801139a0,(%esp)
801036be:	e8 fe 14 00 00       	call   80104bc1 <wakeup>
    release(&log.lock);
801036c3:	c7 04 24 a0 39 11 80 	movl   $0x801139a0,(%esp)
801036ca:	e8 56 18 00 00       	call   80104f25 <release>
  }
}
801036cf:	c9                   	leave  
801036d0:	c3                   	ret    

801036d1 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
801036d1:	55                   	push   %ebp
801036d2:	89 e5                	mov    %esp,%ebp
801036d4:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801036d7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801036de:	e9 89 00 00 00       	jmp    8010376c <write_log+0x9b>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801036e3:	8b 15 d4 39 11 80    	mov    0x801139d4,%edx
801036e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036ec:	01 d0                	add    %edx,%eax
801036ee:	40                   	inc    %eax
801036ef:	89 c2                	mov    %eax,%edx
801036f1:	a1 e4 39 11 80       	mov    0x801139e4,%eax
801036f6:	89 54 24 04          	mov    %edx,0x4(%esp)
801036fa:	89 04 24             	mov    %eax,(%esp)
801036fd:	e8 b3 ca ff ff       	call   801001b5 <bread>
80103702:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103705:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103708:	83 c0 10             	add    $0x10,%eax
8010370b:	8b 04 85 ac 39 11 80 	mov    -0x7feec654(,%eax,4),%eax
80103712:	89 c2                	mov    %eax,%edx
80103714:	a1 e4 39 11 80       	mov    0x801139e4,%eax
80103719:	89 54 24 04          	mov    %edx,0x4(%esp)
8010371d:	89 04 24             	mov    %eax,(%esp)
80103720:	e8 90 ca ff ff       	call   801001b5 <bread>
80103725:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103728:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010372b:	8d 50 5c             	lea    0x5c(%eax),%edx
8010372e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103731:	83 c0 5c             	add    $0x5c,%eax
80103734:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010373b:	00 
8010373c:	89 54 24 04          	mov    %edx,0x4(%esp)
80103740:	89 04 24             	mov    %eax,(%esp)
80103743:	e8 9f 1a 00 00       	call   801051e7 <memmove>
    bwrite(to);  // write the log
80103748:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010374b:	89 04 24             	mov    %eax,(%esp)
8010374e:	e8 99 ca ff ff       	call   801001ec <bwrite>
    brelse(from);
80103753:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103756:	89 04 24             	mov    %eax,(%esp)
80103759:	e8 ce ca ff ff       	call   8010022c <brelse>
    brelse(to);
8010375e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103761:	89 04 24             	mov    %eax,(%esp)
80103764:	e8 c3 ca ff ff       	call   8010022c <brelse>
static void
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103769:	ff 45 f4             	incl   -0xc(%ebp)
8010376c:	a1 e8 39 11 80       	mov    0x801139e8,%eax
80103771:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103774:	0f 8f 69 ff ff ff    	jg     801036e3 <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from);
    brelse(to);
  }
}
8010377a:	c9                   	leave  
8010377b:	c3                   	ret    

8010377c <commit>:

static void
commit()
{
8010377c:	55                   	push   %ebp
8010377d:	89 e5                	mov    %esp,%ebp
8010377f:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103782:	a1 e8 39 11 80       	mov    0x801139e8,%eax
80103787:	85 c0                	test   %eax,%eax
80103789:	7e 1e                	jle    801037a9 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
8010378b:	e8 41 ff ff ff       	call   801036d1 <write_log>
    write_head();    // Write header to disk -- the real commit
80103790:	e8 77 fd ff ff       	call   8010350c <write_head>
    install_trans(); // Now install writes to home locations
80103795:	e8 59 fc ff ff       	call   801033f3 <install_trans>
    log.lh.n = 0;
8010379a:	c7 05 e8 39 11 80 00 	movl   $0x0,0x801139e8
801037a1:	00 00 00 
    write_head();    // Erase the transaction from the log
801037a4:	e8 63 fd ff ff       	call   8010350c <write_head>
  }
}
801037a9:	c9                   	leave  
801037aa:	c3                   	ret    

801037ab <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801037ab:	55                   	push   %ebp
801037ac:	89 e5                	mov    %esp,%ebp
801037ae:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801037b1:	a1 e8 39 11 80       	mov    0x801139e8,%eax
801037b6:	83 f8 1d             	cmp    $0x1d,%eax
801037b9:	7f 10                	jg     801037cb <log_write+0x20>
801037bb:	a1 e8 39 11 80       	mov    0x801139e8,%eax
801037c0:	8b 15 d8 39 11 80    	mov    0x801139d8,%edx
801037c6:	4a                   	dec    %edx
801037c7:	39 d0                	cmp    %edx,%eax
801037c9:	7c 0c                	jl     801037d7 <log_write+0x2c>
    panic("too big a transaction");
801037cb:	c7 04 24 2c 8b 10 80 	movl   $0x80108b2c,(%esp)
801037d2:	e8 7d cd ff ff       	call   80100554 <panic>
  if (log.outstanding < 1)
801037d7:	a1 dc 39 11 80       	mov    0x801139dc,%eax
801037dc:	85 c0                	test   %eax,%eax
801037de:	7f 0c                	jg     801037ec <log_write+0x41>
    panic("log_write outside of trans");
801037e0:	c7 04 24 42 8b 10 80 	movl   $0x80108b42,(%esp)
801037e7:	e8 68 cd ff ff       	call   80100554 <panic>

  acquire(&log.lock);
801037ec:	c7 04 24 a0 39 11 80 	movl   $0x801139a0,(%esp)
801037f3:	e8 c3 16 00 00       	call   80104ebb <acquire>
  for (i = 0; i < log.lh.n; i++) {
801037f8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801037ff:	eb 1e                	jmp    8010381f <log_write+0x74>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103801:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103804:	83 c0 10             	add    $0x10,%eax
80103807:	8b 04 85 ac 39 11 80 	mov    -0x7feec654(,%eax,4),%eax
8010380e:	89 c2                	mov    %eax,%edx
80103810:	8b 45 08             	mov    0x8(%ebp),%eax
80103813:	8b 40 08             	mov    0x8(%eax),%eax
80103816:	39 c2                	cmp    %eax,%edx
80103818:	75 02                	jne    8010381c <log_write+0x71>
      break;
8010381a:	eb 0d                	jmp    80103829 <log_write+0x7e>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
8010381c:	ff 45 f4             	incl   -0xc(%ebp)
8010381f:	a1 e8 39 11 80       	mov    0x801139e8,%eax
80103824:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103827:	7f d8                	jg     80103801 <log_write+0x56>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
  }
  log.lh.block[i] = b->blockno;
80103829:	8b 45 08             	mov    0x8(%ebp),%eax
8010382c:	8b 40 08             	mov    0x8(%eax),%eax
8010382f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103832:	83 c2 10             	add    $0x10,%edx
80103835:	89 04 95 ac 39 11 80 	mov    %eax,-0x7feec654(,%edx,4)
  if (i == log.lh.n)
8010383c:	a1 e8 39 11 80       	mov    0x801139e8,%eax
80103841:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103844:	75 0b                	jne    80103851 <log_write+0xa6>
    log.lh.n++;
80103846:	a1 e8 39 11 80       	mov    0x801139e8,%eax
8010384b:	40                   	inc    %eax
8010384c:	a3 e8 39 11 80       	mov    %eax,0x801139e8
  b->flags |= B_DIRTY; // prevent eviction
80103851:	8b 45 08             	mov    0x8(%ebp),%eax
80103854:	8b 00                	mov    (%eax),%eax
80103856:	83 c8 04             	or     $0x4,%eax
80103859:	89 c2                	mov    %eax,%edx
8010385b:	8b 45 08             	mov    0x8(%ebp),%eax
8010385e:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103860:	c7 04 24 a0 39 11 80 	movl   $0x801139a0,(%esp)
80103867:	e8 b9 16 00 00       	call   80104f25 <release>
}
8010386c:	c9                   	leave  
8010386d:	c3                   	ret    
	...

80103870 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103870:	55                   	push   %ebp
80103871:	89 e5                	mov    %esp,%ebp
80103873:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103876:	8b 55 08             	mov    0x8(%ebp),%edx
80103879:	8b 45 0c             	mov    0xc(%ebp),%eax
8010387c:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010387f:	f0 87 02             	lock xchg %eax,(%edx)
80103882:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103885:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103888:	c9                   	leave  
80103889:	c3                   	ret    

8010388a <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
8010388a:	55                   	push   %ebp
8010388b:	89 e5                	mov    %esp,%ebp
8010388d:	83 e4 f0             	and    $0xfffffff0,%esp
80103890:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103893:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
8010389a:	80 
8010389b:	c7 04 24 50 69 11 80 	movl   $0x80116950,(%esp)
801038a2:	e8 0d f3 ff ff       	call   80102bb4 <kinit1>
  kvmalloc();      // kernel page table
801038a7:	e8 e3 44 00 00       	call   80107d8f <kvmalloc>
  mpinit();        // detect other processors
801038ac:	e8 c4 03 00 00       	call   80103c75 <mpinit>
  lapicinit();     // interrupt controller
801038b1:	e8 4e f6 ff ff       	call   80102f04 <lapicinit>
  seginit();       // segment descriptors
801038b6:	e8 bc 3f 00 00       	call   80107877 <seginit>
  picinit();       // disable pic
801038bb:	e8 04 05 00 00       	call   80103dc4 <picinit>
  ioapicinit();    // another interrupt controller
801038c0:	e8 0c f2 ff ff       	call   80102ad1 <ioapicinit>
  consoleinit();   // console hardware
801038c5:	e8 78 d3 ff ff       	call   80100c42 <consoleinit>
  uartinit();      // serial port
801038ca:	e8 34 33 00 00       	call   80106c03 <uartinit>
  pinit();         // process table
801038cf:	e8 e6 08 00 00       	call   801041ba <pinit>
  tvinit();        // trap vectors
801038d4:	e8 f7 2e 00 00       	call   801067d0 <tvinit>
  binit();         // buffer cache
801038d9:	e8 56 c7 ff ff       	call   80100034 <binit>
  fileinit();      // file table
801038de:	e8 ed d7 ff ff       	call   801010d0 <fileinit>
  ideinit();       // disk 
801038e3:	e8 f5 ed ff ff       	call   801026dd <ideinit>
  startothers();   // start other processors
801038e8:	e8 83 00 00 00       	call   80103970 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801038ed:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
801038f4:	8e 
801038f5:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
801038fc:	e8 eb f2 ff ff       	call   80102bec <kinit2>
  userinit();      // first user process
80103901:	e8 ce 0a 00 00       	call   801043d4 <userinit>
  mpmain();        // finish this processor's setup
80103906:	e8 1a 00 00 00       	call   80103925 <mpmain>

8010390b <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
8010390b:	55                   	push   %ebp
8010390c:	89 e5                	mov    %esp,%ebp
8010390e:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103911:	e8 90 44 00 00       	call   80107da6 <switchkvm>
  seginit();
80103916:	e8 5c 3f 00 00       	call   80107877 <seginit>
  lapicinit();
8010391b:	e8 e4 f5 ff ff       	call   80102f04 <lapicinit>
  mpmain();
80103920:	e8 00 00 00 00       	call   80103925 <mpmain>

80103925 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103925:	55                   	push   %ebp
80103926:	89 e5                	mov    %esp,%ebp
80103928:	53                   	push   %ebx
80103929:	83 ec 14             	sub    $0x14,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
8010392c:	e8 a5 08 00 00       	call   801041d6 <cpuid>
80103931:	89 c3                	mov    %eax,%ebx
80103933:	e8 9e 08 00 00       	call   801041d6 <cpuid>
80103938:	89 5c 24 08          	mov    %ebx,0x8(%esp)
8010393c:	89 44 24 04          	mov    %eax,0x4(%esp)
80103940:	c7 04 24 5d 8b 10 80 	movl   $0x80108b5d,(%esp)
80103947:	e8 75 ca ff ff       	call   801003c1 <cprintf>
  idtinit();       // load idt register
8010394c:	e8 dc 2f 00 00       	call   8010692d <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103951:	e8 c5 08 00 00       	call   8010421b <mycpu>
80103956:	05 a0 00 00 00       	add    $0xa0,%eax
8010395b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80103962:	00 
80103963:	89 04 24             	mov    %eax,(%esp)
80103966:	e8 05 ff ff ff       	call   80103870 <xchg>
  scheduler();     // start running processes
8010396b:	e8 b3 0f 00 00       	call   80104923 <scheduler>

80103970 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103970:	55                   	push   %ebp
80103971:	89 e5                	mov    %esp,%ebp
80103973:	83 ec 28             	sub    $0x28,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103976:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
8010397d:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103982:	89 44 24 08          	mov    %eax,0x8(%esp)
80103986:	c7 44 24 04 2c b5 10 	movl   $0x8010b52c,0x4(%esp)
8010398d:	80 
8010398e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103991:	89 04 24             	mov    %eax,(%esp)
80103994:	e8 4e 18 00 00       	call   801051e7 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80103999:	c7 45 f4 a0 3a 11 80 	movl   $0x80113aa0,-0xc(%ebp)
801039a0:	eb 75                	jmp    80103a17 <startothers+0xa7>
    if(c == mycpu())  // We've started already.
801039a2:	e8 74 08 00 00       	call   8010421b <mycpu>
801039a7:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801039aa:	75 02                	jne    801039ae <startothers+0x3e>
      continue;
801039ac:	eb 62                	jmp    80103a10 <startothers+0xa0>

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801039ae:	e8 2c f3 ff ff       	call   80102cdf <kalloc>
801039b3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801039b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039b9:	83 e8 04             	sub    $0x4,%eax
801039bc:	8b 55 ec             	mov    -0x14(%ebp),%edx
801039bf:	81 c2 00 10 00 00    	add    $0x1000,%edx
801039c5:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
801039c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039ca:	83 e8 08             	sub    $0x8,%eax
801039cd:	c7 00 0b 39 10 80    	movl   $0x8010390b,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801039d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039d6:	8d 50 f4             	lea    -0xc(%eax),%edx
801039d9:	b8 00 a0 10 80       	mov    $0x8010a000,%eax
801039de:	05 00 00 00 80       	add    $0x80000000,%eax
801039e3:	89 02                	mov    %eax,(%edx)

    lapicstartap(c->apicid, V2P(code));
801039e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039e8:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801039ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039f1:	8a 00                	mov    (%eax),%al
801039f3:	0f b6 c0             	movzbl %al,%eax
801039f6:	89 54 24 04          	mov    %edx,0x4(%esp)
801039fa:	89 04 24             	mov    %eax,(%esp)
801039fd:	e8 a7 f6 ff ff       	call   801030a9 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103a02:	90                   	nop
80103a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a06:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103a0c:	85 c0                	test   %eax,%eax
80103a0e:	74 f3                	je     80103a03 <startothers+0x93>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103a10:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103a17:	a1 20 40 11 80       	mov    0x80114020,%eax
80103a1c:	89 c2                	mov    %eax,%edx
80103a1e:	89 d0                	mov    %edx,%eax
80103a20:	c1 e0 02             	shl    $0x2,%eax
80103a23:	01 d0                	add    %edx,%eax
80103a25:	01 c0                	add    %eax,%eax
80103a27:	01 d0                	add    %edx,%eax
80103a29:	c1 e0 04             	shl    $0x4,%eax
80103a2c:	05 a0 3a 11 80       	add    $0x80113aa0,%eax
80103a31:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103a34:	0f 87 68 ff ff ff    	ja     801039a2 <startothers+0x32>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103a3a:	c9                   	leave  
80103a3b:	c3                   	ret    

80103a3c <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103a3c:	55                   	push   %ebp
80103a3d:	89 e5                	mov    %esp,%ebp
80103a3f:	83 ec 14             	sub    $0x14,%esp
80103a42:	8b 45 08             	mov    0x8(%ebp),%eax
80103a45:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103a49:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103a4c:	89 c2                	mov    %eax,%edx
80103a4e:	ec                   	in     (%dx),%al
80103a4f:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103a52:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80103a55:	c9                   	leave  
80103a56:	c3                   	ret    

80103a57 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103a57:	55                   	push   %ebp
80103a58:	89 e5                	mov    %esp,%ebp
80103a5a:	83 ec 08             	sub    $0x8,%esp
80103a5d:	8b 45 08             	mov    0x8(%ebp),%eax
80103a60:	8b 55 0c             	mov    0xc(%ebp),%edx
80103a63:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103a67:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103a6a:	8a 45 f8             	mov    -0x8(%ebp),%al
80103a6d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103a70:	ee                   	out    %al,(%dx)
}
80103a71:	c9                   	leave  
80103a72:	c3                   	ret    

80103a73 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80103a73:	55                   	push   %ebp
80103a74:	89 e5                	mov    %esp,%ebp
80103a76:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
80103a79:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103a80:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103a87:	eb 13                	jmp    80103a9c <sum+0x29>
    sum += addr[i];
80103a89:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103a8c:	8b 45 08             	mov    0x8(%ebp),%eax
80103a8f:	01 d0                	add    %edx,%eax
80103a91:	8a 00                	mov    (%eax),%al
80103a93:	0f b6 c0             	movzbl %al,%eax
80103a96:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
80103a99:	ff 45 fc             	incl   -0x4(%ebp)
80103a9c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103a9f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103aa2:	7c e5                	jl     80103a89 <sum+0x16>
    sum += addr[i];
  return sum;
80103aa4:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103aa7:	c9                   	leave  
80103aa8:	c3                   	ret    

80103aa9 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103aa9:	55                   	push   %ebp
80103aaa:	89 e5                	mov    %esp,%ebp
80103aac:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80103aaf:	8b 45 08             	mov    0x8(%ebp),%eax
80103ab2:	05 00 00 00 80       	add    $0x80000000,%eax
80103ab7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103aba:	8b 55 0c             	mov    0xc(%ebp),%edx
80103abd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ac0:	01 d0                	add    %edx,%eax
80103ac2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103ac5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ac8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103acb:	eb 3f                	jmp    80103b0c <mpsearch1+0x63>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103acd:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103ad4:	00 
80103ad5:	c7 44 24 04 74 8b 10 	movl   $0x80108b74,0x4(%esp)
80103adc:	80 
80103add:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ae0:	89 04 24             	mov    %eax,(%esp)
80103ae3:	e8 ad 16 00 00       	call   80105195 <memcmp>
80103ae8:	85 c0                	test   %eax,%eax
80103aea:	75 1c                	jne    80103b08 <mpsearch1+0x5f>
80103aec:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103af3:	00 
80103af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103af7:	89 04 24             	mov    %eax,(%esp)
80103afa:	e8 74 ff ff ff       	call   80103a73 <sum>
80103aff:	84 c0                	test   %al,%al
80103b01:	75 05                	jne    80103b08 <mpsearch1+0x5f>
      return (struct mp*)p;
80103b03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b06:	eb 11                	jmp    80103b19 <mpsearch1+0x70>
{
  uchar *e, *p, *addr;

  addr = P2V(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103b08:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103b0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b0f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103b12:	72 b9                	jb     80103acd <mpsearch1+0x24>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103b14:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103b19:	c9                   	leave  
80103b1a:	c3                   	ret    

80103b1b <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103b1b:	55                   	push   %ebp
80103b1c:	89 e5                	mov    %esp,%ebp
80103b1e:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103b21:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103b28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b2b:	83 c0 0f             	add    $0xf,%eax
80103b2e:	8a 00                	mov    (%eax),%al
80103b30:	0f b6 c0             	movzbl %al,%eax
80103b33:	c1 e0 08             	shl    $0x8,%eax
80103b36:	89 c2                	mov    %eax,%edx
80103b38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b3b:	83 c0 0e             	add    $0xe,%eax
80103b3e:	8a 00                	mov    (%eax),%al
80103b40:	0f b6 c0             	movzbl %al,%eax
80103b43:	09 d0                	or     %edx,%eax
80103b45:	c1 e0 04             	shl    $0x4,%eax
80103b48:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103b4b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103b4f:	74 21                	je     80103b72 <mpsearch+0x57>
    if((mp = mpsearch1(p, 1024)))
80103b51:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103b58:	00 
80103b59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b5c:	89 04 24             	mov    %eax,(%esp)
80103b5f:	e8 45 ff ff ff       	call   80103aa9 <mpsearch1>
80103b64:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103b67:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103b6b:	74 4e                	je     80103bbb <mpsearch+0xa0>
      return mp;
80103b6d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b70:	eb 5d                	jmp    80103bcf <mpsearch+0xb4>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103b72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b75:	83 c0 14             	add    $0x14,%eax
80103b78:	8a 00                	mov    (%eax),%al
80103b7a:	0f b6 c0             	movzbl %al,%eax
80103b7d:	c1 e0 08             	shl    $0x8,%eax
80103b80:	89 c2                	mov    %eax,%edx
80103b82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b85:	83 c0 13             	add    $0x13,%eax
80103b88:	8a 00                	mov    (%eax),%al
80103b8a:	0f b6 c0             	movzbl %al,%eax
80103b8d:	09 d0                	or     %edx,%eax
80103b8f:	c1 e0 0a             	shl    $0xa,%eax
80103b92:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103b95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b98:	2d 00 04 00 00       	sub    $0x400,%eax
80103b9d:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103ba4:	00 
80103ba5:	89 04 24             	mov    %eax,(%esp)
80103ba8:	e8 fc fe ff ff       	call   80103aa9 <mpsearch1>
80103bad:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103bb0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103bb4:	74 05                	je     80103bbb <mpsearch+0xa0>
      return mp;
80103bb6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103bb9:	eb 14                	jmp    80103bcf <mpsearch+0xb4>
  }
  return mpsearch1(0xF0000, 0x10000);
80103bbb:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103bc2:	00 
80103bc3:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103bca:	e8 da fe ff ff       	call   80103aa9 <mpsearch1>
}
80103bcf:	c9                   	leave  
80103bd0:	c3                   	ret    

80103bd1 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103bd1:	55                   	push   %ebp
80103bd2:	89 e5                	mov    %esp,%ebp
80103bd4:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103bd7:	e8 3f ff ff ff       	call   80103b1b <mpsearch>
80103bdc:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103bdf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103be3:	74 0a                	je     80103bef <mpconfig+0x1e>
80103be5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103be8:	8b 40 04             	mov    0x4(%eax),%eax
80103beb:	85 c0                	test   %eax,%eax
80103bed:	75 07                	jne    80103bf6 <mpconfig+0x25>
    return 0;
80103bef:	b8 00 00 00 00       	mov    $0x0,%eax
80103bf4:	eb 7d                	jmp    80103c73 <mpconfig+0xa2>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103bf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bf9:	8b 40 04             	mov    0x4(%eax),%eax
80103bfc:	05 00 00 00 80       	add    $0x80000000,%eax
80103c01:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103c04:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103c0b:	00 
80103c0c:	c7 44 24 04 79 8b 10 	movl   $0x80108b79,0x4(%esp)
80103c13:	80 
80103c14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c17:	89 04 24             	mov    %eax,(%esp)
80103c1a:	e8 76 15 00 00       	call   80105195 <memcmp>
80103c1f:	85 c0                	test   %eax,%eax
80103c21:	74 07                	je     80103c2a <mpconfig+0x59>
    return 0;
80103c23:	b8 00 00 00 00       	mov    $0x0,%eax
80103c28:	eb 49                	jmp    80103c73 <mpconfig+0xa2>
  if(conf->version != 1 && conf->version != 4)
80103c2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c2d:	8a 40 06             	mov    0x6(%eax),%al
80103c30:	3c 01                	cmp    $0x1,%al
80103c32:	74 11                	je     80103c45 <mpconfig+0x74>
80103c34:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c37:	8a 40 06             	mov    0x6(%eax),%al
80103c3a:	3c 04                	cmp    $0x4,%al
80103c3c:	74 07                	je     80103c45 <mpconfig+0x74>
    return 0;
80103c3e:	b8 00 00 00 00       	mov    $0x0,%eax
80103c43:	eb 2e                	jmp    80103c73 <mpconfig+0xa2>
  if(sum((uchar*)conf, conf->length) != 0)
80103c45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c48:	8b 40 04             	mov    0x4(%eax),%eax
80103c4b:	0f b7 c0             	movzwl %ax,%eax
80103c4e:	89 44 24 04          	mov    %eax,0x4(%esp)
80103c52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c55:	89 04 24             	mov    %eax,(%esp)
80103c58:	e8 16 fe ff ff       	call   80103a73 <sum>
80103c5d:	84 c0                	test   %al,%al
80103c5f:	74 07                	je     80103c68 <mpconfig+0x97>
    return 0;
80103c61:	b8 00 00 00 00       	mov    $0x0,%eax
80103c66:	eb 0b                	jmp    80103c73 <mpconfig+0xa2>
  *pmp = mp;
80103c68:	8b 45 08             	mov    0x8(%ebp),%eax
80103c6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c6e:	89 10                	mov    %edx,(%eax)
  return conf;
80103c70:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103c73:	c9                   	leave  
80103c74:	c3                   	ret    

80103c75 <mpinit>:

void
mpinit(void)
{
80103c75:	55                   	push   %ebp
80103c76:	89 e5                	mov    %esp,%ebp
80103c78:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103c7b:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103c7e:	89 04 24             	mov    %eax,(%esp)
80103c81:	e8 4b ff ff ff       	call   80103bd1 <mpconfig>
80103c86:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c89:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c8d:	75 0c                	jne    80103c9b <mpinit+0x26>
    panic("Expect to run on an SMP");
80103c8f:	c7 04 24 7e 8b 10 80 	movl   $0x80108b7e,(%esp)
80103c96:	e8 b9 c8 ff ff       	call   80100554 <panic>
  ismp = 1;
80103c9b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  lapic = (uint*)conf->lapicaddr;
80103ca2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ca5:	8b 40 24             	mov    0x24(%eax),%eax
80103ca8:	a3 9c 39 11 80       	mov    %eax,0x8011399c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103cad:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103cb0:	83 c0 2c             	add    $0x2c,%eax
80103cb3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103cb6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103cb9:	8b 40 04             	mov    0x4(%eax),%eax
80103cbc:	0f b7 d0             	movzwl %ax,%edx
80103cbf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103cc2:	01 d0                	add    %edx,%eax
80103cc4:	89 45 e8             	mov    %eax,-0x18(%ebp)
80103cc7:	eb 7d                	jmp    80103d46 <mpinit+0xd1>
    switch(*p){
80103cc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ccc:	8a 00                	mov    (%eax),%al
80103cce:	0f b6 c0             	movzbl %al,%eax
80103cd1:	83 f8 04             	cmp    $0x4,%eax
80103cd4:	77 68                	ja     80103d3e <mpinit+0xc9>
80103cd6:	8b 04 85 b8 8b 10 80 	mov    -0x7fef7448(,%eax,4),%eax
80103cdd:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103cdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ce2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(ncpu < NCPU) {
80103ce5:	a1 20 40 11 80       	mov    0x80114020,%eax
80103cea:	83 f8 07             	cmp    $0x7,%eax
80103ced:	7f 2c                	jg     80103d1b <mpinit+0xa6>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103cef:	8b 15 20 40 11 80    	mov    0x80114020,%edx
80103cf5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103cf8:	8a 48 01             	mov    0x1(%eax),%cl
80103cfb:	89 d0                	mov    %edx,%eax
80103cfd:	c1 e0 02             	shl    $0x2,%eax
80103d00:	01 d0                	add    %edx,%eax
80103d02:	01 c0                	add    %eax,%eax
80103d04:	01 d0                	add    %edx,%eax
80103d06:	c1 e0 04             	shl    $0x4,%eax
80103d09:	05 a0 3a 11 80       	add    $0x80113aa0,%eax
80103d0e:	88 08                	mov    %cl,(%eax)
        ncpu++;
80103d10:	a1 20 40 11 80       	mov    0x80114020,%eax
80103d15:	40                   	inc    %eax
80103d16:	a3 20 40 11 80       	mov    %eax,0x80114020
      }
      p += sizeof(struct mpproc);
80103d1b:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103d1f:	eb 25                	jmp    80103d46 <mpinit+0xd1>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103d21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d24:	89 45 e0             	mov    %eax,-0x20(%ebp)
      ioapicid = ioapic->apicno;
80103d27:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d2a:	8a 40 01             	mov    0x1(%eax),%al
80103d2d:	a2 80 3a 11 80       	mov    %al,0x80113a80
      p += sizeof(struct mpioapic);
80103d32:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103d36:	eb 0e                	jmp    80103d46 <mpinit+0xd1>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103d38:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103d3c:	eb 08                	jmp    80103d46 <mpinit+0xd1>
    default:
      ismp = 0;
80103d3e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      break;
80103d45:	90                   	nop

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d49:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80103d4c:	0f 82 77 ff ff ff    	jb     80103cc9 <mpinit+0x54>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
80103d52:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103d56:	75 0c                	jne    80103d64 <mpinit+0xef>
    panic("Didn't find a suitable machine");
80103d58:	c7 04 24 98 8b 10 80 	movl   $0x80108b98,(%esp)
80103d5f:	e8 f0 c7 ff ff       	call   80100554 <panic>

  if(mp->imcrp){
80103d64:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d67:	8a 40 0c             	mov    0xc(%eax),%al
80103d6a:	84 c0                	test   %al,%al
80103d6c:	74 36                	je     80103da4 <mpinit+0x12f>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103d6e:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103d75:	00 
80103d76:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103d7d:	e8 d5 fc ff ff       	call   80103a57 <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103d82:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103d89:	e8 ae fc ff ff       	call   80103a3c <inb>
80103d8e:	83 c8 01             	or     $0x1,%eax
80103d91:	0f b6 c0             	movzbl %al,%eax
80103d94:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d98:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103d9f:	e8 b3 fc ff ff       	call   80103a57 <outb>
  }
}
80103da4:	c9                   	leave  
80103da5:	c3                   	ret    
	...

80103da8 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103da8:	55                   	push   %ebp
80103da9:	89 e5                	mov    %esp,%ebp
80103dab:	83 ec 08             	sub    $0x8,%esp
80103dae:	8b 45 08             	mov    0x8(%ebp),%eax
80103db1:	8b 55 0c             	mov    0xc(%ebp),%edx
80103db4:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103db8:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103dbb:	8a 45 f8             	mov    -0x8(%ebp),%al
80103dbe:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103dc1:	ee                   	out    %al,(%dx)
}
80103dc2:	c9                   	leave  
80103dc3:	c3                   	ret    

80103dc4 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103dc4:	55                   	push   %ebp
80103dc5:	89 e5                	mov    %esp,%ebp
80103dc7:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103dca:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103dd1:	00 
80103dd2:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103dd9:	e8 ca ff ff ff       	call   80103da8 <outb>
  outb(IO_PIC2+1, 0xFF);
80103dde:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103de5:	00 
80103de6:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103ded:	e8 b6 ff ff ff       	call   80103da8 <outb>
}
80103df2:	c9                   	leave  
80103df3:	c3                   	ret    

80103df4 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103df4:	55                   	push   %ebp
80103df5:	89 e5                	mov    %esp,%ebp
80103df7:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103dfa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103e01:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e04:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103e0a:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e0d:	8b 10                	mov    (%eax),%edx
80103e0f:	8b 45 08             	mov    0x8(%ebp),%eax
80103e12:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103e14:	e8 d3 d2 ff ff       	call   801010ec <filealloc>
80103e19:	8b 55 08             	mov    0x8(%ebp),%edx
80103e1c:	89 02                	mov    %eax,(%edx)
80103e1e:	8b 45 08             	mov    0x8(%ebp),%eax
80103e21:	8b 00                	mov    (%eax),%eax
80103e23:	85 c0                	test   %eax,%eax
80103e25:	0f 84 c8 00 00 00    	je     80103ef3 <pipealloc+0xff>
80103e2b:	e8 bc d2 ff ff       	call   801010ec <filealloc>
80103e30:	8b 55 0c             	mov    0xc(%ebp),%edx
80103e33:	89 02                	mov    %eax,(%edx)
80103e35:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e38:	8b 00                	mov    (%eax),%eax
80103e3a:	85 c0                	test   %eax,%eax
80103e3c:	0f 84 b1 00 00 00    	je     80103ef3 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103e42:	e8 98 ee ff ff       	call   80102cdf <kalloc>
80103e47:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103e4a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103e4e:	75 05                	jne    80103e55 <pipealloc+0x61>
    goto bad;
80103e50:	e9 9e 00 00 00       	jmp    80103ef3 <pipealloc+0xff>
  p->readopen = 1;
80103e55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e58:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103e5f:	00 00 00 
  p->writeopen = 1;
80103e62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e65:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103e6c:	00 00 00 
  p->nwrite = 0;
80103e6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e72:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103e79:	00 00 00 
  p->nread = 0;
80103e7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e7f:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103e86:	00 00 00 
  initlock(&p->lock, "pipe");
80103e89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e8c:	c7 44 24 04 cc 8b 10 	movl   $0x80108bcc,0x4(%esp)
80103e93:	80 
80103e94:	89 04 24             	mov    %eax,(%esp)
80103e97:	e8 fe 0f 00 00       	call   80104e9a <initlock>
  (*f0)->type = FD_PIPE;
80103e9c:	8b 45 08             	mov    0x8(%ebp),%eax
80103e9f:	8b 00                	mov    (%eax),%eax
80103ea1:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103ea7:	8b 45 08             	mov    0x8(%ebp),%eax
80103eaa:	8b 00                	mov    (%eax),%eax
80103eac:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103eb0:	8b 45 08             	mov    0x8(%ebp),%eax
80103eb3:	8b 00                	mov    (%eax),%eax
80103eb5:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103eb9:	8b 45 08             	mov    0x8(%ebp),%eax
80103ebc:	8b 00                	mov    (%eax),%eax
80103ebe:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ec1:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103ec4:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ec7:	8b 00                	mov    (%eax),%eax
80103ec9:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103ecf:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ed2:	8b 00                	mov    (%eax),%eax
80103ed4:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103ed8:	8b 45 0c             	mov    0xc(%ebp),%eax
80103edb:	8b 00                	mov    (%eax),%eax
80103edd:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103ee1:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ee4:	8b 00                	mov    (%eax),%eax
80103ee6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ee9:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103eec:	b8 00 00 00 00       	mov    $0x0,%eax
80103ef1:	eb 42                	jmp    80103f35 <pipealloc+0x141>

//PAGEBREAK: 20
 bad:
  if(p)
80103ef3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103ef7:	74 0b                	je     80103f04 <pipealloc+0x110>
    kfree((char*)p);
80103ef9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103efc:	89 04 24             	mov    %eax,(%esp)
80103eff:	e8 45 ed ff ff       	call   80102c49 <kfree>
  if(*f0)
80103f04:	8b 45 08             	mov    0x8(%ebp),%eax
80103f07:	8b 00                	mov    (%eax),%eax
80103f09:	85 c0                	test   %eax,%eax
80103f0b:	74 0d                	je     80103f1a <pipealloc+0x126>
    fileclose(*f0);
80103f0d:	8b 45 08             	mov    0x8(%ebp),%eax
80103f10:	8b 00                	mov    (%eax),%eax
80103f12:	89 04 24             	mov    %eax,(%esp)
80103f15:	e8 7a d2 ff ff       	call   80101194 <fileclose>
  if(*f1)
80103f1a:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f1d:	8b 00                	mov    (%eax),%eax
80103f1f:	85 c0                	test   %eax,%eax
80103f21:	74 0d                	je     80103f30 <pipealloc+0x13c>
    fileclose(*f1);
80103f23:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f26:	8b 00                	mov    (%eax),%eax
80103f28:	89 04 24             	mov    %eax,(%esp)
80103f2b:	e8 64 d2 ff ff       	call   80101194 <fileclose>
  return -1;
80103f30:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103f35:	c9                   	leave  
80103f36:	c3                   	ret    

80103f37 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103f37:	55                   	push   %ebp
80103f38:	89 e5                	mov    %esp,%ebp
80103f3a:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
80103f3d:	8b 45 08             	mov    0x8(%ebp),%eax
80103f40:	89 04 24             	mov    %eax,(%esp)
80103f43:	e8 73 0f 00 00       	call   80104ebb <acquire>
  if(writable){
80103f48:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103f4c:	74 1f                	je     80103f6d <pipeclose+0x36>
    p->writeopen = 0;
80103f4e:	8b 45 08             	mov    0x8(%ebp),%eax
80103f51:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103f58:	00 00 00 
    wakeup(&p->nread);
80103f5b:	8b 45 08             	mov    0x8(%ebp),%eax
80103f5e:	05 34 02 00 00       	add    $0x234,%eax
80103f63:	89 04 24             	mov    %eax,(%esp)
80103f66:	e8 56 0c 00 00       	call   80104bc1 <wakeup>
80103f6b:	eb 1d                	jmp    80103f8a <pipeclose+0x53>
  } else {
    p->readopen = 0;
80103f6d:	8b 45 08             	mov    0x8(%ebp),%eax
80103f70:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103f77:	00 00 00 
    wakeup(&p->nwrite);
80103f7a:	8b 45 08             	mov    0x8(%ebp),%eax
80103f7d:	05 38 02 00 00       	add    $0x238,%eax
80103f82:	89 04 24             	mov    %eax,(%esp)
80103f85:	e8 37 0c 00 00       	call   80104bc1 <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103f8a:	8b 45 08             	mov    0x8(%ebp),%eax
80103f8d:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103f93:	85 c0                	test   %eax,%eax
80103f95:	75 25                	jne    80103fbc <pipeclose+0x85>
80103f97:	8b 45 08             	mov    0x8(%ebp),%eax
80103f9a:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103fa0:	85 c0                	test   %eax,%eax
80103fa2:	75 18                	jne    80103fbc <pipeclose+0x85>
    release(&p->lock);
80103fa4:	8b 45 08             	mov    0x8(%ebp),%eax
80103fa7:	89 04 24             	mov    %eax,(%esp)
80103faa:	e8 76 0f 00 00       	call   80104f25 <release>
    kfree((char*)p);
80103faf:	8b 45 08             	mov    0x8(%ebp),%eax
80103fb2:	89 04 24             	mov    %eax,(%esp)
80103fb5:	e8 8f ec ff ff       	call   80102c49 <kfree>
80103fba:	eb 0b                	jmp    80103fc7 <pipeclose+0x90>
  } else
    release(&p->lock);
80103fbc:	8b 45 08             	mov    0x8(%ebp),%eax
80103fbf:	89 04 24             	mov    %eax,(%esp)
80103fc2:	e8 5e 0f 00 00       	call   80104f25 <release>
}
80103fc7:	c9                   	leave  
80103fc8:	c3                   	ret    

80103fc9 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103fc9:	55                   	push   %ebp
80103fca:	89 e5                	mov    %esp,%ebp
80103fcc:	83 ec 28             	sub    $0x28,%esp
  int i;

  acquire(&p->lock);
80103fcf:	8b 45 08             	mov    0x8(%ebp),%eax
80103fd2:	89 04 24             	mov    %eax,(%esp)
80103fd5:	e8 e1 0e 00 00       	call   80104ebb <acquire>
  for(i = 0; i < n; i++){
80103fda:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103fe1:	e9 a3 00 00 00       	jmp    80104089 <pipewrite+0xc0>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103fe6:	eb 56                	jmp    8010403e <pipewrite+0x75>
      if(p->readopen == 0 || myproc()->killed){
80103fe8:	8b 45 08             	mov    0x8(%ebp),%eax
80103feb:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103ff1:	85 c0                	test   %eax,%eax
80103ff3:	74 0c                	je     80104001 <pipewrite+0x38>
80103ff5:	e8 a5 02 00 00       	call   8010429f <myproc>
80103ffa:	8b 40 24             	mov    0x24(%eax),%eax
80103ffd:	85 c0                	test   %eax,%eax
80103fff:	74 15                	je     80104016 <pipewrite+0x4d>
        release(&p->lock);
80104001:	8b 45 08             	mov    0x8(%ebp),%eax
80104004:	89 04 24             	mov    %eax,(%esp)
80104007:	e8 19 0f 00 00       	call   80104f25 <release>
        return -1;
8010400c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104011:	e9 9d 00 00 00       	jmp    801040b3 <pipewrite+0xea>
      }
      wakeup(&p->nread);
80104016:	8b 45 08             	mov    0x8(%ebp),%eax
80104019:	05 34 02 00 00       	add    $0x234,%eax
8010401e:	89 04 24             	mov    %eax,(%esp)
80104021:	e8 9b 0b 00 00       	call   80104bc1 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104026:	8b 45 08             	mov    0x8(%ebp),%eax
80104029:	8b 55 08             	mov    0x8(%ebp),%edx
8010402c:	81 c2 38 02 00 00    	add    $0x238,%edx
80104032:	89 44 24 04          	mov    %eax,0x4(%esp)
80104036:	89 14 24             	mov    %edx,(%esp)
80104039:	e8 af 0a 00 00       	call   80104aed <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
8010403e:	8b 45 08             	mov    0x8(%ebp),%eax
80104041:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104047:	8b 45 08             	mov    0x8(%ebp),%eax
8010404a:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104050:	05 00 02 00 00       	add    $0x200,%eax
80104055:	39 c2                	cmp    %eax,%edx
80104057:	74 8f                	je     80103fe8 <pipewrite+0x1f>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104059:	8b 45 08             	mov    0x8(%ebp),%eax
8010405c:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104062:	8d 48 01             	lea    0x1(%eax),%ecx
80104065:	8b 55 08             	mov    0x8(%ebp),%edx
80104068:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
8010406e:	25 ff 01 00 00       	and    $0x1ff,%eax
80104073:	89 c1                	mov    %eax,%ecx
80104075:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104078:	8b 45 0c             	mov    0xc(%ebp),%eax
8010407b:	01 d0                	add    %edx,%eax
8010407d:	8a 10                	mov    (%eax),%dl
8010407f:	8b 45 08             	mov    0x8(%ebp),%eax
80104082:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104086:	ff 45 f4             	incl   -0xc(%ebp)
80104089:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010408c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010408f:	0f 8c 51 ff ff ff    	jl     80103fe6 <pipewrite+0x1d>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104095:	8b 45 08             	mov    0x8(%ebp),%eax
80104098:	05 34 02 00 00       	add    $0x234,%eax
8010409d:	89 04 24             	mov    %eax,(%esp)
801040a0:	e8 1c 0b 00 00       	call   80104bc1 <wakeup>
  release(&p->lock);
801040a5:	8b 45 08             	mov    0x8(%ebp),%eax
801040a8:	89 04 24             	mov    %eax,(%esp)
801040ab:	e8 75 0e 00 00       	call   80104f25 <release>
  return n;
801040b0:	8b 45 10             	mov    0x10(%ebp),%eax
}
801040b3:	c9                   	leave  
801040b4:	c3                   	ret    

801040b5 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801040b5:	55                   	push   %ebp
801040b6:	89 e5                	mov    %esp,%ebp
801040b8:	53                   	push   %ebx
801040b9:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
801040bc:	8b 45 08             	mov    0x8(%ebp),%eax
801040bf:	89 04 24             	mov    %eax,(%esp)
801040c2:	e8 f4 0d 00 00       	call   80104ebb <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801040c7:	eb 39                	jmp    80104102 <piperead+0x4d>
    if(myproc()->killed){
801040c9:	e8 d1 01 00 00       	call   8010429f <myproc>
801040ce:	8b 40 24             	mov    0x24(%eax),%eax
801040d1:	85 c0                	test   %eax,%eax
801040d3:	74 15                	je     801040ea <piperead+0x35>
      release(&p->lock);
801040d5:	8b 45 08             	mov    0x8(%ebp),%eax
801040d8:	89 04 24             	mov    %eax,(%esp)
801040db:	e8 45 0e 00 00       	call   80104f25 <release>
      return -1;
801040e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040e5:	e9 b3 00 00 00       	jmp    8010419d <piperead+0xe8>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801040ea:	8b 45 08             	mov    0x8(%ebp),%eax
801040ed:	8b 55 08             	mov    0x8(%ebp),%edx
801040f0:	81 c2 34 02 00 00    	add    $0x234,%edx
801040f6:	89 44 24 04          	mov    %eax,0x4(%esp)
801040fa:	89 14 24             	mov    %edx,(%esp)
801040fd:	e8 eb 09 00 00       	call   80104aed <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104102:	8b 45 08             	mov    0x8(%ebp),%eax
80104105:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010410b:	8b 45 08             	mov    0x8(%ebp),%eax
8010410e:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104114:	39 c2                	cmp    %eax,%edx
80104116:	75 0d                	jne    80104125 <piperead+0x70>
80104118:	8b 45 08             	mov    0x8(%ebp),%eax
8010411b:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104121:	85 c0                	test   %eax,%eax
80104123:	75 a4                	jne    801040c9 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104125:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010412c:	eb 49                	jmp    80104177 <piperead+0xc2>
    if(p->nread == p->nwrite)
8010412e:	8b 45 08             	mov    0x8(%ebp),%eax
80104131:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104137:	8b 45 08             	mov    0x8(%ebp),%eax
8010413a:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104140:	39 c2                	cmp    %eax,%edx
80104142:	75 02                	jne    80104146 <piperead+0x91>
      break;
80104144:	eb 39                	jmp    8010417f <piperead+0xca>
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104146:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104149:	8b 45 0c             	mov    0xc(%ebp),%eax
8010414c:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010414f:	8b 45 08             	mov    0x8(%ebp),%eax
80104152:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104158:	8d 48 01             	lea    0x1(%eax),%ecx
8010415b:	8b 55 08             	mov    0x8(%ebp),%edx
8010415e:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104164:	25 ff 01 00 00       	and    $0x1ff,%eax
80104169:	89 c2                	mov    %eax,%edx
8010416b:	8b 45 08             	mov    0x8(%ebp),%eax
8010416e:	8a 44 10 34          	mov    0x34(%eax,%edx,1),%al
80104172:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104174:	ff 45 f4             	incl   -0xc(%ebp)
80104177:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010417a:	3b 45 10             	cmp    0x10(%ebp),%eax
8010417d:	7c af                	jl     8010412e <piperead+0x79>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
8010417f:	8b 45 08             	mov    0x8(%ebp),%eax
80104182:	05 38 02 00 00       	add    $0x238,%eax
80104187:	89 04 24             	mov    %eax,(%esp)
8010418a:	e8 32 0a 00 00       	call   80104bc1 <wakeup>
  release(&p->lock);
8010418f:	8b 45 08             	mov    0x8(%ebp),%eax
80104192:	89 04 24             	mov    %eax,(%esp)
80104195:	e8 8b 0d 00 00       	call   80104f25 <release>
  return i;
8010419a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010419d:	83 c4 24             	add    $0x24,%esp
801041a0:	5b                   	pop    %ebx
801041a1:	5d                   	pop    %ebp
801041a2:	c3                   	ret    
	...

801041a4 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801041a4:	55                   	push   %ebp
801041a5:	89 e5                	mov    %esp,%ebp
801041a7:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801041aa:	9c                   	pushf  
801041ab:	58                   	pop    %eax
801041ac:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801041af:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801041b2:	c9                   	leave  
801041b3:	c3                   	ret    

801041b4 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
801041b4:	55                   	push   %ebp
801041b5:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801041b7:	fb                   	sti    
}
801041b8:	5d                   	pop    %ebp
801041b9:	c3                   	ret    

801041ba <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
801041ba:	55                   	push   %ebp
801041bb:	89 e5                	mov    %esp,%ebp
801041bd:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
801041c0:	c7 44 24 04 d4 8b 10 	movl   $0x80108bd4,0x4(%esp)
801041c7:	80 
801041c8:	c7 04 24 40 40 11 80 	movl   $0x80114040,(%esp)
801041cf:	e8 c6 0c 00 00       	call   80104e9a <initlock>
}
801041d4:	c9                   	leave  
801041d5:	c3                   	ret    

801041d6 <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
801041d6:	55                   	push   %ebp
801041d7:	89 e5                	mov    %esp,%ebp
801041d9:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
801041dc:	e8 3a 00 00 00       	call   8010421b <mycpu>
801041e1:	89 c2                	mov    %eax,%edx
801041e3:	b8 a0 3a 11 80       	mov    $0x80113aa0,%eax
801041e8:	29 c2                	sub    %eax,%edx
801041ea:	89 d0                	mov    %edx,%eax
801041ec:	c1 f8 04             	sar    $0x4,%eax
801041ef:	89 c1                	mov    %eax,%ecx
801041f1:	89 ca                	mov    %ecx,%edx
801041f3:	c1 e2 03             	shl    $0x3,%edx
801041f6:	01 ca                	add    %ecx,%edx
801041f8:	89 d0                	mov    %edx,%eax
801041fa:	c1 e0 05             	shl    $0x5,%eax
801041fd:	29 d0                	sub    %edx,%eax
801041ff:	c1 e0 02             	shl    $0x2,%eax
80104202:	01 c8                	add    %ecx,%eax
80104204:	c1 e0 03             	shl    $0x3,%eax
80104207:	01 c8                	add    %ecx,%eax
80104209:	89 c2                	mov    %eax,%edx
8010420b:	c1 e2 0f             	shl    $0xf,%edx
8010420e:	29 c2                	sub    %eax,%edx
80104210:	c1 e2 02             	shl    $0x2,%edx
80104213:	01 ca                	add    %ecx,%edx
80104215:	89 d0                	mov    %edx,%eax
80104217:	f7 d8                	neg    %eax
}
80104219:	c9                   	leave  
8010421a:	c3                   	ret    

8010421b <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
8010421b:	55                   	push   %ebp
8010421c:	89 e5                	mov    %esp,%ebp
8010421e:	83 ec 28             	sub    $0x28,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF)
80104221:	e8 7e ff ff ff       	call   801041a4 <readeflags>
80104226:	25 00 02 00 00       	and    $0x200,%eax
8010422b:	85 c0                	test   %eax,%eax
8010422d:	74 0c                	je     8010423b <mycpu+0x20>
    panic("mycpu called with interrupts enabled\n");
8010422f:	c7 04 24 dc 8b 10 80 	movl   $0x80108bdc,(%esp)
80104236:	e8 19 c3 ff ff       	call   80100554 <panic>
  
  apicid = lapicid();
8010423b:	e8 1d ee ff ff       	call   8010305d <lapicid>
80104240:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80104243:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010424a:	eb 3b                	jmp    80104287 <mycpu+0x6c>
    if (cpus[i].apicid == apicid)
8010424c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010424f:	89 d0                	mov    %edx,%eax
80104251:	c1 e0 02             	shl    $0x2,%eax
80104254:	01 d0                	add    %edx,%eax
80104256:	01 c0                	add    %eax,%eax
80104258:	01 d0                	add    %edx,%eax
8010425a:	c1 e0 04             	shl    $0x4,%eax
8010425d:	05 a0 3a 11 80       	add    $0x80113aa0,%eax
80104262:	8a 00                	mov    (%eax),%al
80104264:	0f b6 c0             	movzbl %al,%eax
80104267:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010426a:	75 18                	jne    80104284 <mycpu+0x69>
      return &cpus[i];
8010426c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010426f:	89 d0                	mov    %edx,%eax
80104271:	c1 e0 02             	shl    $0x2,%eax
80104274:	01 d0                	add    %edx,%eax
80104276:	01 c0                	add    %eax,%eax
80104278:	01 d0                	add    %edx,%eax
8010427a:	c1 e0 04             	shl    $0x4,%eax
8010427d:	05 a0 3a 11 80       	add    $0x80113aa0,%eax
80104282:	eb 19                	jmp    8010429d <mycpu+0x82>
    panic("mycpu called with interrupts enabled\n");
  
  apicid = lapicid();
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80104284:	ff 45 f4             	incl   -0xc(%ebp)
80104287:	a1 20 40 11 80       	mov    0x80114020,%eax
8010428c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010428f:	7c bb                	jl     8010424c <mycpu+0x31>
    if (cpus[i].apicid == apicid)
      return &cpus[i];
  }
  panic("unknown apicid\n");
80104291:	c7 04 24 02 8c 10 80 	movl   $0x80108c02,(%esp)
80104298:	e8 b7 c2 ff ff       	call   80100554 <panic>
}
8010429d:	c9                   	leave  
8010429e:	c3                   	ret    

8010429f <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
8010429f:	55                   	push   %ebp
801042a0:	89 e5                	mov    %esp,%ebp
801042a2:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
801042a5:	e8 70 0d 00 00       	call   8010501a <pushcli>
  c = mycpu();
801042aa:	e8 6c ff ff ff       	call   8010421b <mycpu>
801042af:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
801042b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042b5:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801042bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
801042be:	e8 a1 0d 00 00       	call   80105064 <popcli>
  return p;
801042c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801042c6:	c9                   	leave  
801042c7:	c3                   	ret    

801042c8 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
801042c8:	55                   	push   %ebp
801042c9:	89 e5                	mov    %esp,%ebp
801042cb:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
801042ce:	c7 04 24 40 40 11 80 	movl   $0x80114040,(%esp)
801042d5:	e8 e1 0b 00 00       	call   80104ebb <acquire>

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801042da:	c7 45 f4 74 40 11 80 	movl   $0x80114074,-0xc(%ebp)
801042e1:	eb 50                	jmp    80104333 <allocproc+0x6b>
    if(p->state == UNUSED)
801042e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042e6:	8b 40 0c             	mov    0xc(%eax),%eax
801042e9:	85 c0                	test   %eax,%eax
801042eb:	75 42                	jne    8010432f <allocproc+0x67>
      goto found;
801042ed:	90                   	nop

  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
801042ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042f1:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
801042f8:	a1 00 b0 10 80       	mov    0x8010b000,%eax
801042fd:	8d 50 01             	lea    0x1(%eax),%edx
80104300:	89 15 00 b0 10 80    	mov    %edx,0x8010b000
80104306:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104309:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
8010430c:	c7 04 24 40 40 11 80 	movl   $0x80114040,(%esp)
80104313:	e8 0d 0c 00 00       	call   80104f25 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104318:	e8 c2 e9 ff ff       	call   80102cdf <kalloc>
8010431d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104320:	89 42 08             	mov    %eax,0x8(%edx)
80104323:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104326:	8b 40 08             	mov    0x8(%eax),%eax
80104329:	85 c0                	test   %eax,%eax
8010432b:	75 36                	jne    80104363 <allocproc+0x9b>
8010432d:	eb 23                	jmp    80104352 <allocproc+0x8a>
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010432f:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104333:	81 7d f4 74 60 11 80 	cmpl   $0x80116074,-0xc(%ebp)
8010433a:	72 a7                	jb     801042e3 <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;

  release(&ptable.lock);
8010433c:	c7 04 24 40 40 11 80 	movl   $0x80114040,(%esp)
80104343:	e8 dd 0b 00 00       	call   80104f25 <release>
  return 0;
80104348:	b8 00 00 00 00       	mov    $0x0,%eax
8010434d:	e9 80 00 00 00       	jmp    801043d2 <allocproc+0x10a>

  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
80104352:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104355:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
8010435c:	b8 00 00 00 00       	mov    $0x0,%eax
80104361:	eb 6f                	jmp    801043d2 <allocproc+0x10a>
  }
  sp = p->kstack + KSTACKSIZE;
80104363:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104366:	8b 40 08             	mov    0x8(%eax),%eax
80104369:	05 00 10 00 00       	add    $0x1000,%eax
8010436e:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104371:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104375:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104378:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010437b:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
8010437e:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104382:	ba 8c 67 10 80       	mov    $0x8010678c,%edx
80104387:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010438a:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
8010438c:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104390:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104393:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104396:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104399:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010439c:	8b 40 1c             	mov    0x1c(%eax),%eax
8010439f:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
801043a6:	00 
801043a7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801043ae:	00 
801043af:	89 04 24             	mov    %eax,(%esp)
801043b2:	e8 67 0d 00 00       	call   8010511e <memset>
  p->context->eip = (uint)forkret;
801043b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ba:	8b 40 1c             	mov    0x1c(%eax),%eax
801043bd:	ba ae 4a 10 80       	mov    $0x80104aae,%edx
801043c2:	89 50 10             	mov    %edx,0x10(%eax)

  p->ticks = 0;
801043c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043c8:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)

  return p;
801043cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801043d2:	c9                   	leave  
801043d3:	c3                   	ret    

801043d4 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801043d4:	55                   	push   %ebp
801043d5:	89 e5                	mov    %esp,%ebp
801043d7:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
801043da:	e8 e9 fe ff ff       	call   801042c8 <allocproc>
801043df:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
801043e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043e5:	a3 c0 b8 10 80       	mov    %eax,0x8010b8c0
  if((p->pgdir = setupkvm()) == 0)
801043ea:	e8 f7 38 00 00       	call   80107ce6 <setupkvm>
801043ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043f2:	89 42 04             	mov    %eax,0x4(%edx)
801043f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043f8:	8b 40 04             	mov    0x4(%eax),%eax
801043fb:	85 c0                	test   %eax,%eax
801043fd:	75 0c                	jne    8010440b <userinit+0x37>
    panic("userinit: out of memory?");
801043ff:	c7 04 24 12 8c 10 80 	movl   $0x80108c12,(%esp)
80104406:	e8 49 c1 ff ff       	call   80100554 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
8010440b:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104410:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104413:	8b 40 04             	mov    0x4(%eax),%eax
80104416:	89 54 24 08          	mov    %edx,0x8(%esp)
8010441a:	c7 44 24 04 00 b5 10 	movl   $0x8010b500,0x4(%esp)
80104421:	80 
80104422:	89 04 24             	mov    %eax,(%esp)
80104425:	e8 1d 3b 00 00       	call   80107f47 <inituvm>
  p->sz = PGSIZE;
8010442a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010442d:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104433:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104436:	8b 40 18             	mov    0x18(%eax),%eax
80104439:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
80104440:	00 
80104441:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104448:	00 
80104449:	89 04 24             	mov    %eax,(%esp)
8010444c:	e8 cd 0c 00 00       	call   8010511e <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104451:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104454:	8b 40 18             	mov    0x18(%eax),%eax
80104457:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
8010445d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104460:	8b 40 18             	mov    0x18(%eax),%eax
80104463:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104469:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010446c:	8b 50 18             	mov    0x18(%eax),%edx
8010446f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104472:	8b 40 18             	mov    0x18(%eax),%eax
80104475:	8b 40 2c             	mov    0x2c(%eax),%eax
80104478:	66 89 42 28          	mov    %ax,0x28(%edx)
  p->tf->ss = p->tf->ds;
8010447c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010447f:	8b 50 18             	mov    0x18(%eax),%edx
80104482:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104485:	8b 40 18             	mov    0x18(%eax),%eax
80104488:	8b 40 2c             	mov    0x2c(%eax),%eax
8010448b:	66 89 42 48          	mov    %ax,0x48(%edx)
  p->tf->eflags = FL_IF;
8010448f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104492:	8b 40 18             	mov    0x18(%eax),%eax
80104495:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
8010449c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010449f:	8b 40 18             	mov    0x18(%eax),%eax
801044a2:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801044a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ac:	8b 40 18             	mov    0x18(%eax),%eax
801044af:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
801044b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044b9:	83 c0 6c             	add    $0x6c,%eax
801044bc:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801044c3:	00 
801044c4:	c7 44 24 04 2b 8c 10 	movl   $0x80108c2b,0x4(%esp)
801044cb:	80 
801044cc:	89 04 24             	mov    %eax,(%esp)
801044cf:	e8 56 0e 00 00       	call   8010532a <safestrcpy>
  p->cwd = namei("/");
801044d4:	c7 04 24 34 8c 10 80 	movl   $0x80108c34,(%esp)
801044db:	e8 f3 e0 ff ff       	call   801025d3 <namei>
801044e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044e3:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
801044e6:	c7 04 24 40 40 11 80 	movl   $0x80114040,(%esp)
801044ed:	e8 c9 09 00 00       	call   80104ebb <acquire>

  p->state = RUNNABLE;
801044f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044f5:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
801044fc:	c7 04 24 40 40 11 80 	movl   $0x80114040,(%esp)
80104503:	e8 1d 0a 00 00       	call   80104f25 <release>
}
80104508:	c9                   	leave  
80104509:	c3                   	ret    

8010450a <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
8010450a:	55                   	push   %ebp
8010450b:	89 e5                	mov    %esp,%ebp
8010450d:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  struct proc *curproc = myproc();
80104510:	e8 8a fd ff ff       	call   8010429f <myproc>
80104515:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80104518:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010451b:	8b 00                	mov    (%eax),%eax
8010451d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104520:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104524:	7e 31                	jle    80104557 <growproc+0x4d>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104526:	8b 55 08             	mov    0x8(%ebp),%edx
80104529:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010452c:	01 c2                	add    %eax,%edx
8010452e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104531:	8b 40 04             	mov    0x4(%eax),%eax
80104534:	89 54 24 08          	mov    %edx,0x8(%esp)
80104538:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010453b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010453f:	89 04 24             	mov    %eax,(%esp)
80104542:	e8 6b 3b 00 00       	call   801080b2 <allocuvm>
80104547:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010454a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010454e:	75 3e                	jne    8010458e <growproc+0x84>
      return -1;
80104550:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104555:	eb 4f                	jmp    801045a6 <growproc+0x9c>
  } else if(n < 0){
80104557:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010455b:	79 31                	jns    8010458e <growproc+0x84>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
8010455d:	8b 55 08             	mov    0x8(%ebp),%edx
80104560:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104563:	01 c2                	add    %eax,%edx
80104565:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104568:	8b 40 04             	mov    0x4(%eax),%eax
8010456b:	89 54 24 08          	mov    %edx,0x8(%esp)
8010456f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104572:	89 54 24 04          	mov    %edx,0x4(%esp)
80104576:	89 04 24             	mov    %eax,(%esp)
80104579:	e8 4a 3c 00 00       	call   801081c8 <deallocuvm>
8010457e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104581:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104585:	75 07                	jne    8010458e <growproc+0x84>
      return -1;
80104587:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010458c:	eb 18                	jmp    801045a6 <growproc+0x9c>
  }
  curproc->sz = sz;
8010458e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104591:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104594:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80104596:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104599:	89 04 24             	mov    %eax,(%esp)
8010459c:	e8 1f 38 00 00       	call   80107dc0 <switchuvm>
  return 0;
801045a1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801045a6:	c9                   	leave  
801045a7:	c3                   	ret    

801045a8 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
801045a8:	55                   	push   %ebp
801045a9:	89 e5                	mov    %esp,%ebp
801045ab:	57                   	push   %edi
801045ac:	56                   	push   %esi
801045ad:	53                   	push   %ebx
801045ae:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
801045b1:	e8 e9 fc ff ff       	call   8010429f <myproc>
801045b6:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
801045b9:	e8 0a fd ff ff       	call   801042c8 <allocproc>
801045be:	89 45 dc             	mov    %eax,-0x24(%ebp)
801045c1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
801045c5:	75 0a                	jne    801045d1 <fork+0x29>
    return -1;
801045c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045cc:	e9 35 01 00 00       	jmp    80104706 <fork+0x15e>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
801045d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801045d4:	8b 10                	mov    (%eax),%edx
801045d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801045d9:	8b 40 04             	mov    0x4(%eax),%eax
801045dc:	89 54 24 04          	mov    %edx,0x4(%esp)
801045e0:	89 04 24             	mov    %eax,(%esp)
801045e3:	e8 80 3d 00 00       	call   80108368 <copyuvm>
801045e8:	8b 55 dc             	mov    -0x24(%ebp),%edx
801045eb:	89 42 04             	mov    %eax,0x4(%edx)
801045ee:	8b 45 dc             	mov    -0x24(%ebp),%eax
801045f1:	8b 40 04             	mov    0x4(%eax),%eax
801045f4:	85 c0                	test   %eax,%eax
801045f6:	75 2c                	jne    80104624 <fork+0x7c>
    kfree(np->kstack);
801045f8:	8b 45 dc             	mov    -0x24(%ebp),%eax
801045fb:	8b 40 08             	mov    0x8(%eax),%eax
801045fe:	89 04 24             	mov    %eax,(%esp)
80104601:	e8 43 e6 ff ff       	call   80102c49 <kfree>
    np->kstack = 0;
80104606:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104609:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104610:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104613:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
8010461a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010461f:	e9 e2 00 00 00       	jmp    80104706 <fork+0x15e>
  }
  np->sz = curproc->sz;
80104624:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104627:	8b 10                	mov    (%eax),%edx
80104629:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010462c:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
8010462e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104631:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104634:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80104637:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010463a:	8b 50 18             	mov    0x18(%eax),%edx
8010463d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104640:	8b 40 18             	mov    0x18(%eax),%eax
80104643:	89 c3                	mov    %eax,%ebx
80104645:	b8 13 00 00 00       	mov    $0x13,%eax
8010464a:	89 d7                	mov    %edx,%edi
8010464c:	89 de                	mov    %ebx,%esi
8010464e:	89 c1                	mov    %eax,%ecx
80104650:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104652:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104655:	8b 40 18             	mov    0x18(%eax),%eax
80104658:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
8010465f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104666:	eb 36                	jmp    8010469e <fork+0xf6>
    if(curproc->ofile[i])
80104668:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010466b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010466e:	83 c2 08             	add    $0x8,%edx
80104671:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104675:	85 c0                	test   %eax,%eax
80104677:	74 22                	je     8010469b <fork+0xf3>
      np->ofile[i] = filedup(curproc->ofile[i]);
80104679:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010467c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010467f:	83 c2 08             	add    $0x8,%edx
80104682:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104686:	89 04 24             	mov    %eax,(%esp)
80104689:	e8 be ca ff ff       	call   8010114c <filedup>
8010468e:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104691:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104694:	83 c1 08             	add    $0x8,%ecx
80104697:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *curproc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
8010469b:	ff 45 e4             	incl   -0x1c(%ebp)
8010469e:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
801046a2:	7e c4                	jle    80104668 <fork+0xc0>
    if(curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);
801046a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046a7:	8b 40 68             	mov    0x68(%eax),%eax
801046aa:	89 04 24             	mov    %eax,(%esp)
801046ad:	e8 ca d3 ff ff       	call   80101a7c <idup>
801046b2:	8b 55 dc             	mov    -0x24(%ebp),%edx
801046b5:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
801046b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046bb:	8d 50 6c             	lea    0x6c(%eax),%edx
801046be:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046c1:	83 c0 6c             	add    $0x6c,%eax
801046c4:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801046cb:	00 
801046cc:	89 54 24 04          	mov    %edx,0x4(%esp)
801046d0:	89 04 24             	mov    %eax,(%esp)
801046d3:	e8 52 0c 00 00       	call   8010532a <safestrcpy>

  pid = np->pid;
801046d8:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046db:	8b 40 10             	mov    0x10(%eax),%eax
801046de:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
801046e1:	c7 04 24 40 40 11 80 	movl   $0x80114040,(%esp)
801046e8:	e8 ce 07 00 00       	call   80104ebb <acquire>

  np->state = RUNNABLE;
801046ed:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046f0:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
801046f7:	c7 04 24 40 40 11 80 	movl   $0x80114040,(%esp)
801046fe:	e8 22 08 00 00       	call   80104f25 <release>

  return pid;
80104703:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80104706:	83 c4 2c             	add    $0x2c,%esp
80104709:	5b                   	pop    %ebx
8010470a:	5e                   	pop    %esi
8010470b:	5f                   	pop    %edi
8010470c:	5d                   	pop    %ebp
8010470d:	c3                   	ret    

8010470e <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
8010470e:	55                   	push   %ebp
8010470f:	89 e5                	mov    %esp,%ebp
80104711:	83 ec 28             	sub    $0x28,%esp
  struct proc *curproc = myproc();
80104714:	e8 86 fb ff ff       	call   8010429f <myproc>
80104719:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
8010471c:	a1 c0 b8 10 80       	mov    0x8010b8c0,%eax
80104721:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104724:	75 0c                	jne    80104732 <exit+0x24>
    panic("init exiting");
80104726:	c7 04 24 36 8c 10 80 	movl   $0x80108c36,(%esp)
8010472d:	e8 22 be ff ff       	call   80100554 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104732:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104739:	eb 3a                	jmp    80104775 <exit+0x67>
    if(curproc->ofile[fd]){
8010473b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010473e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104741:	83 c2 08             	add    $0x8,%edx
80104744:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104748:	85 c0                	test   %eax,%eax
8010474a:	74 26                	je     80104772 <exit+0x64>
      fileclose(curproc->ofile[fd]);
8010474c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010474f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104752:	83 c2 08             	add    $0x8,%edx
80104755:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104759:	89 04 24             	mov    %eax,(%esp)
8010475c:	e8 33 ca ff ff       	call   80101194 <fileclose>
      curproc->ofile[fd] = 0;
80104761:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104764:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104767:	83 c2 08             	add    $0x8,%edx
8010476a:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104771:	00 

  if(curproc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104772:	ff 45 f0             	incl   -0x10(%ebp)
80104775:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104779:	7e c0                	jle    8010473b <exit+0x2d>
      fileclose(curproc->ofile[fd]);
      curproc->ofile[fd] = 0;
    }
  }

  begin_op();
8010477b:	e8 27 ee ff ff       	call   801035a7 <begin_op>
  iput(curproc->cwd);
80104780:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104783:	8b 40 68             	mov    0x68(%eax),%eax
80104786:	89 04 24             	mov    %eax,(%esp)
80104789:	e8 6e d4 ff ff       	call   80101bfc <iput>
  end_op();
8010478e:	e8 96 ee ff ff       	call   80103629 <end_op>
  curproc->cwd = 0;
80104793:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104796:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
8010479d:	c7 04 24 40 40 11 80 	movl   $0x80114040,(%esp)
801047a4:	e8 12 07 00 00       	call   80104ebb <acquire>

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
801047a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047ac:	8b 40 14             	mov    0x14(%eax),%eax
801047af:	89 04 24             	mov    %eax,(%esp)
801047b2:	e8 cc 03 00 00       	call   80104b83 <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801047b7:	c7 45 f4 74 40 11 80 	movl   $0x80114074,-0xc(%ebp)
801047be:	eb 33                	jmp    801047f3 <exit+0xe5>
    if(p->parent == curproc){
801047c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047c3:	8b 40 14             	mov    0x14(%eax),%eax
801047c6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801047c9:	75 24                	jne    801047ef <exit+0xe1>
      p->parent = initproc;
801047cb:	8b 15 c0 b8 10 80    	mov    0x8010b8c0,%edx
801047d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047d4:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801047d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047da:	8b 40 0c             	mov    0xc(%eax),%eax
801047dd:	83 f8 05             	cmp    $0x5,%eax
801047e0:	75 0d                	jne    801047ef <exit+0xe1>
        wakeup1(initproc);
801047e2:	a1 c0 b8 10 80       	mov    0x8010b8c0,%eax
801047e7:	89 04 24             	mov    %eax,(%esp)
801047ea:	e8 94 03 00 00       	call   80104b83 <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801047ef:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801047f3:	81 7d f4 74 60 11 80 	cmpl   $0x80116074,-0xc(%ebp)
801047fa:	72 c4                	jb     801047c0 <exit+0xb2>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
801047fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047ff:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104806:	e8 c3 01 00 00       	call   801049ce <sched>
  panic("zombie exit");
8010480b:	c7 04 24 43 8c 10 80 	movl   $0x80108c43,(%esp)
80104812:	e8 3d bd ff ff       	call   80100554 <panic>

80104817 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104817:	55                   	push   %ebp
80104818:	89 e5                	mov    %esp,%ebp
8010481a:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
8010481d:	e8 7d fa ff ff       	call   8010429f <myproc>
80104822:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80104825:	c7 04 24 40 40 11 80 	movl   $0x80114040,(%esp)
8010482c:	e8 8a 06 00 00       	call   80104ebb <acquire>
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104831:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104838:	c7 45 f4 74 40 11 80 	movl   $0x80114074,-0xc(%ebp)
8010483f:	e9 95 00 00 00       	jmp    801048d9 <wait+0xc2>
      if(p->parent != curproc)
80104844:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104847:	8b 40 14             	mov    0x14(%eax),%eax
8010484a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010484d:	74 05                	je     80104854 <wait+0x3d>
        continue;
8010484f:	e9 81 00 00 00       	jmp    801048d5 <wait+0xbe>
      havekids = 1;
80104854:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
8010485b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010485e:	8b 40 0c             	mov    0xc(%eax),%eax
80104861:	83 f8 05             	cmp    $0x5,%eax
80104864:	75 6f                	jne    801048d5 <wait+0xbe>
        // Found one.
        pid = p->pid;
80104866:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104869:	8b 40 10             	mov    0x10(%eax),%eax
8010486c:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
8010486f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104872:	8b 40 08             	mov    0x8(%eax),%eax
80104875:	89 04 24             	mov    %eax,(%esp)
80104878:	e8 cc e3 ff ff       	call   80102c49 <kfree>
        p->kstack = 0;
8010487d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104880:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104887:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010488a:	8b 40 04             	mov    0x4(%eax),%eax
8010488d:	89 04 24             	mov    %eax,(%esp)
80104890:	e8 f7 39 00 00       	call   8010828c <freevm>
        p->pid = 0;
80104895:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104898:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
8010489f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048a2:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
801048a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048ac:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
801048b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048b3:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
801048ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048bd:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
801048c4:	c7 04 24 40 40 11 80 	movl   $0x80114040,(%esp)
801048cb:	e8 55 06 00 00       	call   80104f25 <release>
        return pid;
801048d0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801048d3:	eb 4c                	jmp    80104921 <wait+0x10a>
  
  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048d5:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801048d9:	81 7d f4 74 60 11 80 	cmpl   $0x80116074,-0xc(%ebp)
801048e0:	0f 82 5e ff ff ff    	jb     80104844 <wait+0x2d>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
801048e6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801048ea:	74 0a                	je     801048f6 <wait+0xdf>
801048ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
801048ef:	8b 40 24             	mov    0x24(%eax),%eax
801048f2:	85 c0                	test   %eax,%eax
801048f4:	74 13                	je     80104909 <wait+0xf2>
      release(&ptable.lock);
801048f6:	c7 04 24 40 40 11 80 	movl   $0x80114040,(%esp)
801048fd:	e8 23 06 00 00       	call   80104f25 <release>
      return -1;
80104902:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104907:	eb 18                	jmp    80104921 <wait+0x10a>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80104909:	c7 44 24 04 40 40 11 	movl   $0x80114040,0x4(%esp)
80104910:	80 
80104911:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104914:	89 04 24             	mov    %eax,(%esp)
80104917:	e8 d1 01 00 00       	call   80104aed <sleep>
  }
8010491c:	e9 10 ff ff ff       	jmp    80104831 <wait+0x1a>
}
80104921:	c9                   	leave  
80104922:	c3                   	ret    

80104923 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104923:	55                   	push   %ebp
80104924:	89 e5                	mov    %esp,%ebp
80104926:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104929:	e8 ed f8 ff ff       	call   8010421b <mycpu>
8010492e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104931:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104934:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010493b:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
8010493e:	e8 71 f8 ff ff       	call   801041b4 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104943:	c7 04 24 40 40 11 80 	movl   $0x80114040,(%esp)
8010494a:	e8 6c 05 00 00       	call   80104ebb <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010494f:	c7 45 f4 74 40 11 80 	movl   $0x80114074,-0xc(%ebp)
80104956:	eb 5c                	jmp    801049b4 <scheduler+0x91>
      if(p->state != RUNNABLE)
80104958:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010495b:	8b 40 0c             	mov    0xc(%eax),%eax
8010495e:	83 f8 03             	cmp    $0x3,%eax
80104961:	74 02                	je     80104965 <scheduler+0x42>
        continue;
80104963:	eb 4b                	jmp    801049b0 <scheduler+0x8d>

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104965:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104968:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010496b:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104971:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104974:	89 04 24             	mov    %eax,(%esp)
80104977:	e8 44 34 00 00       	call   80107dc0 <switchuvm>
      p->state = RUNNING;
8010497c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010497f:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104986:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104989:	8b 40 1c             	mov    0x1c(%eax),%eax
8010498c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010498f:	83 c2 04             	add    $0x4,%edx
80104992:	89 44 24 04          	mov    %eax,0x4(%esp)
80104996:	89 14 24             	mov    %edx,(%esp)
80104999:	e8 fa 09 00 00       	call   80105398 <swtch>
      switchkvm();
8010499e:	e8 03 34 00 00       	call   80107da6 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
801049a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049a6:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801049ad:	00 00 00 
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049b0:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801049b4:	81 7d f4 74 60 11 80 	cmpl   $0x80116074,-0xc(%ebp)
801049bb:	72 9b                	jb     80104958 <scheduler+0x35>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
    }
    release(&ptable.lock);
801049bd:	c7 04 24 40 40 11 80 	movl   $0x80114040,(%esp)
801049c4:	e8 5c 05 00 00       	call   80104f25 <release>

  }
801049c9:	e9 70 ff ff ff       	jmp    8010493e <scheduler+0x1b>

801049ce <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
801049ce:	55                   	push   %ebp
801049cf:	89 e5                	mov    %esp,%ebp
801049d1:	83 ec 28             	sub    $0x28,%esp
  int intena;
  struct proc *p = myproc();
801049d4:	e8 c6 f8 ff ff       	call   8010429f <myproc>
801049d9:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
801049dc:	c7 04 24 40 40 11 80 	movl   $0x80114040,(%esp)
801049e3:	e8 01 06 00 00       	call   80104fe9 <holding>
801049e8:	85 c0                	test   %eax,%eax
801049ea:	75 0c                	jne    801049f8 <sched+0x2a>
    panic("sched ptable.lock");
801049ec:	c7 04 24 4f 8c 10 80 	movl   $0x80108c4f,(%esp)
801049f3:	e8 5c bb ff ff       	call   80100554 <panic>
  if(mycpu()->ncli != 1)
801049f8:	e8 1e f8 ff ff       	call   8010421b <mycpu>
801049fd:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104a03:	83 f8 01             	cmp    $0x1,%eax
80104a06:	74 0c                	je     80104a14 <sched+0x46>
    panic("sched locks");
80104a08:	c7 04 24 61 8c 10 80 	movl   $0x80108c61,(%esp)
80104a0f:	e8 40 bb ff ff       	call   80100554 <panic>
  if(p->state == RUNNING)
80104a14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a17:	8b 40 0c             	mov    0xc(%eax),%eax
80104a1a:	83 f8 04             	cmp    $0x4,%eax
80104a1d:	75 0c                	jne    80104a2b <sched+0x5d>
    panic("sched running");
80104a1f:	c7 04 24 6d 8c 10 80 	movl   $0x80108c6d,(%esp)
80104a26:	e8 29 bb ff ff       	call   80100554 <panic>
  if(readeflags()&FL_IF)
80104a2b:	e8 74 f7 ff ff       	call   801041a4 <readeflags>
80104a30:	25 00 02 00 00       	and    $0x200,%eax
80104a35:	85 c0                	test   %eax,%eax
80104a37:	74 0c                	je     80104a45 <sched+0x77>
    panic("sched interruptible");
80104a39:	c7 04 24 7b 8c 10 80 	movl   $0x80108c7b,(%esp)
80104a40:	e8 0f bb ff ff       	call   80100554 <panic>
  intena = mycpu()->intena;
80104a45:	e8 d1 f7 ff ff       	call   8010421b <mycpu>
80104a4a:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104a50:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104a53:	e8 c3 f7 ff ff       	call   8010421b <mycpu>
80104a58:	8b 40 04             	mov    0x4(%eax),%eax
80104a5b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104a5e:	83 c2 1c             	add    $0x1c,%edx
80104a61:	89 44 24 04          	mov    %eax,0x4(%esp)
80104a65:	89 14 24             	mov    %edx,(%esp)
80104a68:	e8 2b 09 00 00       	call   80105398 <swtch>
  mycpu()->intena = intena;
80104a6d:	e8 a9 f7 ff ff       	call   8010421b <mycpu>
80104a72:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a75:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104a7b:	c9                   	leave  
80104a7c:	c3                   	ret    

80104a7d <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104a7d:	55                   	push   %ebp
80104a7e:	89 e5                	mov    %esp,%ebp
80104a80:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104a83:	c7 04 24 40 40 11 80 	movl   $0x80114040,(%esp)
80104a8a:	e8 2c 04 00 00       	call   80104ebb <acquire>
  myproc()->state = RUNNABLE;
80104a8f:	e8 0b f8 ff ff       	call   8010429f <myproc>
80104a94:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104a9b:	e8 2e ff ff ff       	call   801049ce <sched>
  release(&ptable.lock);
80104aa0:	c7 04 24 40 40 11 80 	movl   $0x80114040,(%esp)
80104aa7:	e8 79 04 00 00       	call   80104f25 <release>
}
80104aac:	c9                   	leave  
80104aad:	c3                   	ret    

80104aae <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104aae:	55                   	push   %ebp
80104aaf:	89 e5                	mov    %esp,%ebp
80104ab1:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104ab4:	c7 04 24 40 40 11 80 	movl   $0x80114040,(%esp)
80104abb:	e8 65 04 00 00       	call   80104f25 <release>

  if (first) {
80104ac0:	a1 04 b0 10 80       	mov    0x8010b004,%eax
80104ac5:	85 c0                	test   %eax,%eax
80104ac7:	74 22                	je     80104aeb <forkret+0x3d>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104ac9:	c7 05 04 b0 10 80 00 	movl   $0x0,0x8010b004
80104ad0:	00 00 00 
    iinit(ROOTDEV);
80104ad3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104ada:	e8 68 cc ff ff       	call   80101747 <iinit>
    initlog(ROOTDEV);
80104adf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104ae6:	e8 bd e8 ff ff       	call   801033a8 <initlog>
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104aeb:	c9                   	leave  
80104aec:	c3                   	ret    

80104aed <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104aed:	55                   	push   %ebp
80104aee:	89 e5                	mov    %esp,%ebp
80104af0:	83 ec 28             	sub    $0x28,%esp
  struct proc *p = myproc();
80104af3:	e8 a7 f7 ff ff       	call   8010429f <myproc>
80104af8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104afb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104aff:	75 0c                	jne    80104b0d <sleep+0x20>
    panic("sleep");
80104b01:	c7 04 24 8f 8c 10 80 	movl   $0x80108c8f,(%esp)
80104b08:	e8 47 ba ff ff       	call   80100554 <panic>

  if(lk == 0)
80104b0d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104b11:	75 0c                	jne    80104b1f <sleep+0x32>
    panic("sleep without lk");
80104b13:	c7 04 24 95 8c 10 80 	movl   $0x80108c95,(%esp)
80104b1a:	e8 35 ba ff ff       	call   80100554 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104b1f:	81 7d 0c 40 40 11 80 	cmpl   $0x80114040,0xc(%ebp)
80104b26:	74 17                	je     80104b3f <sleep+0x52>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104b28:	c7 04 24 40 40 11 80 	movl   $0x80114040,(%esp)
80104b2f:	e8 87 03 00 00       	call   80104ebb <acquire>
    release(lk);
80104b34:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b37:	89 04 24             	mov    %eax,(%esp)
80104b3a:	e8 e6 03 00 00       	call   80104f25 <release>
  }
  // Go to sleep.
  p->chan = chan;
80104b3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b42:	8b 55 08             	mov    0x8(%ebp),%edx
80104b45:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104b48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b4b:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104b52:	e8 77 fe ff ff       	call   801049ce <sched>

  // Tidy up.
  p->chan = 0;
80104b57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b5a:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104b61:	81 7d 0c 40 40 11 80 	cmpl   $0x80114040,0xc(%ebp)
80104b68:	74 17                	je     80104b81 <sleep+0x94>
    release(&ptable.lock);
80104b6a:	c7 04 24 40 40 11 80 	movl   $0x80114040,(%esp)
80104b71:	e8 af 03 00 00       	call   80104f25 <release>
    acquire(lk);
80104b76:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b79:	89 04 24             	mov    %eax,(%esp)
80104b7c:	e8 3a 03 00 00       	call   80104ebb <acquire>
  }
}
80104b81:	c9                   	leave  
80104b82:	c3                   	ret    

80104b83 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104b83:	55                   	push   %ebp
80104b84:	89 e5                	mov    %esp,%ebp
80104b86:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104b89:	c7 45 fc 74 40 11 80 	movl   $0x80114074,-0x4(%ebp)
80104b90:	eb 24                	jmp    80104bb6 <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104b92:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b95:	8b 40 0c             	mov    0xc(%eax),%eax
80104b98:	83 f8 02             	cmp    $0x2,%eax
80104b9b:	75 15                	jne    80104bb2 <wakeup1+0x2f>
80104b9d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ba0:	8b 40 20             	mov    0x20(%eax),%eax
80104ba3:	3b 45 08             	cmp    0x8(%ebp),%eax
80104ba6:	75 0a                	jne    80104bb2 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104ba8:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104bab:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104bb2:	83 6d fc 80          	subl   $0xffffff80,-0x4(%ebp)
80104bb6:	81 7d fc 74 60 11 80 	cmpl   $0x80116074,-0x4(%ebp)
80104bbd:	72 d3                	jb     80104b92 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104bbf:	c9                   	leave  
80104bc0:	c3                   	ret    

80104bc1 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104bc1:	55                   	push   %ebp
80104bc2:	89 e5                	mov    %esp,%ebp
80104bc4:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104bc7:	c7 04 24 40 40 11 80 	movl   $0x80114040,(%esp)
80104bce:	e8 e8 02 00 00       	call   80104ebb <acquire>
  wakeup1(chan);
80104bd3:	8b 45 08             	mov    0x8(%ebp),%eax
80104bd6:	89 04 24             	mov    %eax,(%esp)
80104bd9:	e8 a5 ff ff ff       	call   80104b83 <wakeup1>
  release(&ptable.lock);
80104bde:	c7 04 24 40 40 11 80 	movl   $0x80114040,(%esp)
80104be5:	e8 3b 03 00 00       	call   80104f25 <release>
}
80104bea:	c9                   	leave  
80104beb:	c3                   	ret    

80104bec <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104bec:	55                   	push   %ebp
80104bed:	89 e5                	mov    %esp,%ebp
80104bef:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104bf2:	c7 04 24 40 40 11 80 	movl   $0x80114040,(%esp)
80104bf9:	e8 bd 02 00 00       	call   80104ebb <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104bfe:	c7 45 f4 74 40 11 80 	movl   $0x80114074,-0xc(%ebp)
80104c05:	eb 41                	jmp    80104c48 <kill+0x5c>
    if(p->pid == pid){
80104c07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c0a:	8b 40 10             	mov    0x10(%eax),%eax
80104c0d:	3b 45 08             	cmp    0x8(%ebp),%eax
80104c10:	75 32                	jne    80104c44 <kill+0x58>
      p->killed = 1;
80104c12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c15:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104c1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c1f:	8b 40 0c             	mov    0xc(%eax),%eax
80104c22:	83 f8 02             	cmp    $0x2,%eax
80104c25:	75 0a                	jne    80104c31 <kill+0x45>
        p->state = RUNNABLE;
80104c27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c2a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104c31:	c7 04 24 40 40 11 80 	movl   $0x80114040,(%esp)
80104c38:	e8 e8 02 00 00       	call   80104f25 <release>
      return 0;
80104c3d:	b8 00 00 00 00       	mov    $0x0,%eax
80104c42:	eb 1e                	jmp    80104c62 <kill+0x76>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c44:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104c48:	81 7d f4 74 60 11 80 	cmpl   $0x80116074,-0xc(%ebp)
80104c4f:	72 b6                	jb     80104c07 <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104c51:	c7 04 24 40 40 11 80 	movl   $0x80114040,(%esp)
80104c58:	e8 c8 02 00 00       	call   80104f25 <release>
  return -1;
80104c5d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104c62:	c9                   	leave  
80104c63:	c3                   	ret    

80104c64 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104c64:	55                   	push   %ebp
80104c65:	89 e5                	mov    %esp,%ebp
80104c67:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c6a:	c7 45 f0 74 40 11 80 	movl   $0x80114074,-0x10(%ebp)
80104c71:	e9 d5 00 00 00       	jmp    80104d4b <procdump+0xe7>
    if(p->state == UNUSED)
80104c76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c79:	8b 40 0c             	mov    0xc(%eax),%eax
80104c7c:	85 c0                	test   %eax,%eax
80104c7e:	75 05                	jne    80104c85 <procdump+0x21>
      continue;
80104c80:	e9 c2 00 00 00       	jmp    80104d47 <procdump+0xe3>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104c85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c88:	8b 40 0c             	mov    0xc(%eax),%eax
80104c8b:	83 f8 05             	cmp    $0x5,%eax
80104c8e:	77 23                	ja     80104cb3 <procdump+0x4f>
80104c90:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c93:	8b 40 0c             	mov    0xc(%eax),%eax
80104c96:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104c9d:	85 c0                	test   %eax,%eax
80104c9f:	74 12                	je     80104cb3 <procdump+0x4f>
      state = states[p->state];
80104ca1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ca4:	8b 40 0c             	mov    0xc(%eax),%eax
80104ca7:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104cae:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104cb1:	eb 07                	jmp    80104cba <procdump+0x56>
    else
      state = "???";
80104cb3:	c7 45 ec a6 8c 10 80 	movl   $0x80108ca6,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104cba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cbd:	8d 50 6c             	lea    0x6c(%eax),%edx
80104cc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cc3:	8b 40 10             	mov    0x10(%eax),%eax
80104cc6:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104cca:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104ccd:	89 54 24 08          	mov    %edx,0x8(%esp)
80104cd1:	89 44 24 04          	mov    %eax,0x4(%esp)
80104cd5:	c7 04 24 aa 8c 10 80 	movl   $0x80108caa,(%esp)
80104cdc:	e8 e0 b6 ff ff       	call   801003c1 <cprintf>
    if(p->state == SLEEPING){
80104ce1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ce4:	8b 40 0c             	mov    0xc(%eax),%eax
80104ce7:	83 f8 02             	cmp    $0x2,%eax
80104cea:	75 4f                	jne    80104d3b <procdump+0xd7>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104cec:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cef:	8b 40 1c             	mov    0x1c(%eax),%eax
80104cf2:	8b 40 0c             	mov    0xc(%eax),%eax
80104cf5:	83 c0 08             	add    $0x8,%eax
80104cf8:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80104cfb:	89 54 24 04          	mov    %edx,0x4(%esp)
80104cff:	89 04 24             	mov    %eax,(%esp)
80104d02:	e8 6b 02 00 00       	call   80104f72 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104d07:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104d0e:	eb 1a                	jmp    80104d2a <procdump+0xc6>
        cprintf(" %p", pc[i]);
80104d10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d13:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104d17:	89 44 24 04          	mov    %eax,0x4(%esp)
80104d1b:	c7 04 24 b3 8c 10 80 	movl   $0x80108cb3,(%esp)
80104d22:	e8 9a b6 ff ff       	call   801003c1 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104d27:	ff 45 f4             	incl   -0xc(%ebp)
80104d2a:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104d2e:	7f 0b                	jg     80104d3b <procdump+0xd7>
80104d30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d33:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104d37:	85 c0                	test   %eax,%eax
80104d39:	75 d5                	jne    80104d10 <procdump+0xac>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104d3b:	c7 04 24 b7 8c 10 80 	movl   $0x80108cb7,(%esp)
80104d42:	e8 7a b6 ff ff       	call   801003c1 <cprintf>
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d47:	83 6d f0 80          	subl   $0xffffff80,-0x10(%ebp)
80104d4b:	81 7d f0 74 60 11 80 	cmpl   $0x80116074,-0x10(%ebp)
80104d52:	0f 82 1e ff ff ff    	jb     80104c76 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104d58:	c9                   	leave  
80104d59:	c3                   	ret    
	...

80104d5c <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104d5c:	55                   	push   %ebp
80104d5d:	89 e5                	mov    %esp,%ebp
80104d5f:	83 ec 18             	sub    $0x18,%esp
  initlock(&lk->lk, "sleep lock");
80104d62:	8b 45 08             	mov    0x8(%ebp),%eax
80104d65:	83 c0 04             	add    $0x4,%eax
80104d68:	c7 44 24 04 e3 8c 10 	movl   $0x80108ce3,0x4(%esp)
80104d6f:	80 
80104d70:	89 04 24             	mov    %eax,(%esp)
80104d73:	e8 22 01 00 00       	call   80104e9a <initlock>
  lk->name = name;
80104d78:	8b 45 08             	mov    0x8(%ebp),%eax
80104d7b:	8b 55 0c             	mov    0xc(%ebp),%edx
80104d7e:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104d81:	8b 45 08             	mov    0x8(%ebp),%eax
80104d84:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104d8a:	8b 45 08             	mov    0x8(%ebp),%eax
80104d8d:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104d94:	c9                   	leave  
80104d95:	c3                   	ret    

80104d96 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104d96:	55                   	push   %ebp
80104d97:	89 e5                	mov    %esp,%ebp
80104d99:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
80104d9c:	8b 45 08             	mov    0x8(%ebp),%eax
80104d9f:	83 c0 04             	add    $0x4,%eax
80104da2:	89 04 24             	mov    %eax,(%esp)
80104da5:	e8 11 01 00 00       	call   80104ebb <acquire>
  while (lk->locked) {
80104daa:	eb 15                	jmp    80104dc1 <acquiresleep+0x2b>
    sleep(lk, &lk->lk);
80104dac:	8b 45 08             	mov    0x8(%ebp),%eax
80104daf:	83 c0 04             	add    $0x4,%eax
80104db2:	89 44 24 04          	mov    %eax,0x4(%esp)
80104db6:	8b 45 08             	mov    0x8(%ebp),%eax
80104db9:	89 04 24             	mov    %eax,(%esp)
80104dbc:	e8 2c fd ff ff       	call   80104aed <sleep>

void
acquiresleep(struct sleeplock *lk)
{
  acquire(&lk->lk);
  while (lk->locked) {
80104dc1:	8b 45 08             	mov    0x8(%ebp),%eax
80104dc4:	8b 00                	mov    (%eax),%eax
80104dc6:	85 c0                	test   %eax,%eax
80104dc8:	75 e2                	jne    80104dac <acquiresleep+0x16>
    sleep(lk, &lk->lk);
  }
  lk->locked = 1;
80104dca:	8b 45 08             	mov    0x8(%ebp),%eax
80104dcd:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104dd3:	e8 c7 f4 ff ff       	call   8010429f <myproc>
80104dd8:	8b 50 10             	mov    0x10(%eax),%edx
80104ddb:	8b 45 08             	mov    0x8(%ebp),%eax
80104dde:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104de1:	8b 45 08             	mov    0x8(%ebp),%eax
80104de4:	83 c0 04             	add    $0x4,%eax
80104de7:	89 04 24             	mov    %eax,(%esp)
80104dea:	e8 36 01 00 00       	call   80104f25 <release>
}
80104def:	c9                   	leave  
80104df0:	c3                   	ret    

80104df1 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104df1:	55                   	push   %ebp
80104df2:	89 e5                	mov    %esp,%ebp
80104df4:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
80104df7:	8b 45 08             	mov    0x8(%ebp),%eax
80104dfa:	83 c0 04             	add    $0x4,%eax
80104dfd:	89 04 24             	mov    %eax,(%esp)
80104e00:	e8 b6 00 00 00       	call   80104ebb <acquire>
  lk->locked = 0;
80104e05:	8b 45 08             	mov    0x8(%ebp),%eax
80104e08:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104e0e:	8b 45 08             	mov    0x8(%ebp),%eax
80104e11:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104e18:	8b 45 08             	mov    0x8(%ebp),%eax
80104e1b:	89 04 24             	mov    %eax,(%esp)
80104e1e:	e8 9e fd ff ff       	call   80104bc1 <wakeup>
  release(&lk->lk);
80104e23:	8b 45 08             	mov    0x8(%ebp),%eax
80104e26:	83 c0 04             	add    $0x4,%eax
80104e29:	89 04 24             	mov    %eax,(%esp)
80104e2c:	e8 f4 00 00 00       	call   80104f25 <release>
}
80104e31:	c9                   	leave  
80104e32:	c3                   	ret    

80104e33 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104e33:	55                   	push   %ebp
80104e34:	89 e5                	mov    %esp,%ebp
80104e36:	83 ec 28             	sub    $0x28,%esp
  int r;
  
  acquire(&lk->lk);
80104e39:	8b 45 08             	mov    0x8(%ebp),%eax
80104e3c:	83 c0 04             	add    $0x4,%eax
80104e3f:	89 04 24             	mov    %eax,(%esp)
80104e42:	e8 74 00 00 00       	call   80104ebb <acquire>
  r = lk->locked;
80104e47:	8b 45 08             	mov    0x8(%ebp),%eax
80104e4a:	8b 00                	mov    (%eax),%eax
80104e4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104e4f:	8b 45 08             	mov    0x8(%ebp),%eax
80104e52:	83 c0 04             	add    $0x4,%eax
80104e55:	89 04 24             	mov    %eax,(%esp)
80104e58:	e8 c8 00 00 00       	call   80104f25 <release>
  return r;
80104e5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104e60:	c9                   	leave  
80104e61:	c3                   	ret    
	...

80104e64 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104e64:	55                   	push   %ebp
80104e65:	89 e5                	mov    %esp,%ebp
80104e67:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104e6a:	9c                   	pushf  
80104e6b:	58                   	pop    %eax
80104e6c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104e6f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104e72:	c9                   	leave  
80104e73:	c3                   	ret    

80104e74 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80104e74:	55                   	push   %ebp
80104e75:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104e77:	fa                   	cli    
}
80104e78:	5d                   	pop    %ebp
80104e79:	c3                   	ret    

80104e7a <sti>:

static inline void
sti(void)
{
80104e7a:	55                   	push   %ebp
80104e7b:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104e7d:	fb                   	sti    
}
80104e7e:	5d                   	pop    %ebp
80104e7f:	c3                   	ret    

80104e80 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80104e80:	55                   	push   %ebp
80104e81:	89 e5                	mov    %esp,%ebp
80104e83:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80104e86:	8b 55 08             	mov    0x8(%ebp),%edx
80104e89:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e8c:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104e8f:	f0 87 02             	lock xchg %eax,(%edx)
80104e92:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80104e95:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104e98:	c9                   	leave  
80104e99:	c3                   	ret    

80104e9a <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104e9a:	55                   	push   %ebp
80104e9b:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104e9d:	8b 45 08             	mov    0x8(%ebp),%eax
80104ea0:	8b 55 0c             	mov    0xc(%ebp),%edx
80104ea3:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104ea6:	8b 45 08             	mov    0x8(%ebp),%eax
80104ea9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104eaf:	8b 45 08             	mov    0x8(%ebp),%eax
80104eb2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104eb9:	5d                   	pop    %ebp
80104eba:	c3                   	ret    

80104ebb <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104ebb:	55                   	push   %ebp
80104ebc:	89 e5                	mov    %esp,%ebp
80104ebe:	53                   	push   %ebx
80104ebf:	83 ec 14             	sub    $0x14,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104ec2:	e8 53 01 00 00       	call   8010501a <pushcli>
  if(holding(lk))
80104ec7:	8b 45 08             	mov    0x8(%ebp),%eax
80104eca:	89 04 24             	mov    %eax,(%esp)
80104ecd:	e8 17 01 00 00       	call   80104fe9 <holding>
80104ed2:	85 c0                	test   %eax,%eax
80104ed4:	74 0c                	je     80104ee2 <acquire+0x27>
    panic("acquire");
80104ed6:	c7 04 24 ee 8c 10 80 	movl   $0x80108cee,(%esp)
80104edd:	e8 72 b6 ff ff       	call   80100554 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104ee2:	90                   	nop
80104ee3:	8b 45 08             	mov    0x8(%ebp),%eax
80104ee6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80104eed:	00 
80104eee:	89 04 24             	mov    %eax,(%esp)
80104ef1:	e8 8a ff ff ff       	call   80104e80 <xchg>
80104ef6:	85 c0                	test   %eax,%eax
80104ef8:	75 e9                	jne    80104ee3 <acquire+0x28>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104efa:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104eff:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104f02:	e8 14 f3 ff ff       	call   8010421b <mycpu>
80104f07:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104f0a:	8b 45 08             	mov    0x8(%ebp),%eax
80104f0d:	83 c0 0c             	add    $0xc,%eax
80104f10:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f14:	8d 45 08             	lea    0x8(%ebp),%eax
80104f17:	89 04 24             	mov    %eax,(%esp)
80104f1a:	e8 53 00 00 00       	call   80104f72 <getcallerpcs>
}
80104f1f:	83 c4 14             	add    $0x14,%esp
80104f22:	5b                   	pop    %ebx
80104f23:	5d                   	pop    %ebp
80104f24:	c3                   	ret    

80104f25 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104f25:	55                   	push   %ebp
80104f26:	89 e5                	mov    %esp,%ebp
80104f28:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
80104f2b:	8b 45 08             	mov    0x8(%ebp),%eax
80104f2e:	89 04 24             	mov    %eax,(%esp)
80104f31:	e8 b3 00 00 00       	call   80104fe9 <holding>
80104f36:	85 c0                	test   %eax,%eax
80104f38:	75 0c                	jne    80104f46 <release+0x21>
    panic("release");
80104f3a:	c7 04 24 f6 8c 10 80 	movl   $0x80108cf6,(%esp)
80104f41:	e8 0e b6 ff ff       	call   80100554 <panic>

  lk->pcs[0] = 0;
80104f46:	8b 45 08             	mov    0x8(%ebp),%eax
80104f49:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104f50:	8b 45 08             	mov    0x8(%ebp),%eax
80104f53:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80104f5a:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104f5f:	8b 45 08             	mov    0x8(%ebp),%eax
80104f62:	8b 55 08             	mov    0x8(%ebp),%edx
80104f65:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80104f6b:	e8 f4 00 00 00       	call   80105064 <popcli>
}
80104f70:	c9                   	leave  
80104f71:	c3                   	ret    

80104f72 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104f72:	55                   	push   %ebp
80104f73:	89 e5                	mov    %esp,%ebp
80104f75:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104f78:	8b 45 08             	mov    0x8(%ebp),%eax
80104f7b:	83 e8 08             	sub    $0x8,%eax
80104f7e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104f81:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104f88:	eb 37                	jmp    80104fc1 <getcallerpcs+0x4f>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104f8a:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104f8e:	74 37                	je     80104fc7 <getcallerpcs+0x55>
80104f90:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104f97:	76 2e                	jbe    80104fc7 <getcallerpcs+0x55>
80104f99:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104f9d:	74 28                	je     80104fc7 <getcallerpcs+0x55>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104f9f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104fa2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104fa9:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fac:	01 c2                	add    %eax,%edx
80104fae:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104fb1:	8b 40 04             	mov    0x4(%eax),%eax
80104fb4:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104fb6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104fb9:	8b 00                	mov    (%eax),%eax
80104fbb:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80104fbe:	ff 45 f8             	incl   -0x8(%ebp)
80104fc1:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104fc5:	7e c3                	jle    80104f8a <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80104fc7:	eb 18                	jmp    80104fe1 <getcallerpcs+0x6f>
    pcs[i] = 0;
80104fc9:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104fcc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104fd3:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fd6:	01 d0                	add    %edx,%eax
80104fd8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80104fde:	ff 45 f8             	incl   -0x8(%ebp)
80104fe1:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104fe5:	7e e2                	jle    80104fc9 <getcallerpcs+0x57>
    pcs[i] = 0;
}
80104fe7:	c9                   	leave  
80104fe8:	c3                   	ret    

80104fe9 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104fe9:	55                   	push   %ebp
80104fea:	89 e5                	mov    %esp,%ebp
80104fec:	53                   	push   %ebx
80104fed:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104ff0:	8b 45 08             	mov    0x8(%ebp),%eax
80104ff3:	8b 00                	mov    (%eax),%eax
80104ff5:	85 c0                	test   %eax,%eax
80104ff7:	74 16                	je     8010500f <holding+0x26>
80104ff9:	8b 45 08             	mov    0x8(%ebp),%eax
80104ffc:	8b 58 08             	mov    0x8(%eax),%ebx
80104fff:	e8 17 f2 ff ff       	call   8010421b <mycpu>
80105004:	39 c3                	cmp    %eax,%ebx
80105006:	75 07                	jne    8010500f <holding+0x26>
80105008:	b8 01 00 00 00       	mov    $0x1,%eax
8010500d:	eb 05                	jmp    80105014 <holding+0x2b>
8010500f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105014:	83 c4 04             	add    $0x4,%esp
80105017:	5b                   	pop    %ebx
80105018:	5d                   	pop    %ebp
80105019:	c3                   	ret    

8010501a <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
8010501a:	55                   	push   %ebp
8010501b:	89 e5                	mov    %esp,%ebp
8010501d:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80105020:	e8 3f fe ff ff       	call   80104e64 <readeflags>
80105025:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80105028:	e8 47 fe ff ff       	call   80104e74 <cli>
  if(mycpu()->ncli == 0)
8010502d:	e8 e9 f1 ff ff       	call   8010421b <mycpu>
80105032:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105038:	85 c0                	test   %eax,%eax
8010503a:	75 14                	jne    80105050 <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
8010503c:	e8 da f1 ff ff       	call   8010421b <mycpu>
80105041:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105044:	81 e2 00 02 00 00    	and    $0x200,%edx
8010504a:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80105050:	e8 c6 f1 ff ff       	call   8010421b <mycpu>
80105055:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
8010505b:	42                   	inc    %edx
8010505c:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80105062:	c9                   	leave  
80105063:	c3                   	ret    

80105064 <popcli>:

void
popcli(void)
{
80105064:	55                   	push   %ebp
80105065:	89 e5                	mov    %esp,%ebp
80105067:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
8010506a:	e8 f5 fd ff ff       	call   80104e64 <readeflags>
8010506f:	25 00 02 00 00       	and    $0x200,%eax
80105074:	85 c0                	test   %eax,%eax
80105076:	74 0c                	je     80105084 <popcli+0x20>
    panic("popcli - interruptible");
80105078:	c7 04 24 fe 8c 10 80 	movl   $0x80108cfe,(%esp)
8010507f:	e8 d0 b4 ff ff       	call   80100554 <panic>
  if(--mycpu()->ncli < 0)
80105084:	e8 92 f1 ff ff       	call   8010421b <mycpu>
80105089:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
8010508f:	4a                   	dec    %edx
80105090:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80105096:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010509c:	85 c0                	test   %eax,%eax
8010509e:	79 0c                	jns    801050ac <popcli+0x48>
    panic("popcli");
801050a0:	c7 04 24 15 8d 10 80 	movl   $0x80108d15,(%esp)
801050a7:	e8 a8 b4 ff ff       	call   80100554 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
801050ac:	e8 6a f1 ff ff       	call   8010421b <mycpu>
801050b1:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801050b7:	85 c0                	test   %eax,%eax
801050b9:	75 14                	jne    801050cf <popcli+0x6b>
801050bb:	e8 5b f1 ff ff       	call   8010421b <mycpu>
801050c0:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801050c6:	85 c0                	test   %eax,%eax
801050c8:	74 05                	je     801050cf <popcli+0x6b>
    sti();
801050ca:	e8 ab fd ff ff       	call   80104e7a <sti>
}
801050cf:	c9                   	leave  
801050d0:	c3                   	ret    
801050d1:	00 00                	add    %al,(%eax)
	...

801050d4 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
801050d4:	55                   	push   %ebp
801050d5:	89 e5                	mov    %esp,%ebp
801050d7:	57                   	push   %edi
801050d8:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801050d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
801050dc:	8b 55 10             	mov    0x10(%ebp),%edx
801050df:	8b 45 0c             	mov    0xc(%ebp),%eax
801050e2:	89 cb                	mov    %ecx,%ebx
801050e4:	89 df                	mov    %ebx,%edi
801050e6:	89 d1                	mov    %edx,%ecx
801050e8:	fc                   	cld    
801050e9:	f3 aa                	rep stos %al,%es:(%edi)
801050eb:	89 ca                	mov    %ecx,%edx
801050ed:	89 fb                	mov    %edi,%ebx
801050ef:	89 5d 08             	mov    %ebx,0x8(%ebp)
801050f2:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801050f5:	5b                   	pop    %ebx
801050f6:	5f                   	pop    %edi
801050f7:	5d                   	pop    %ebp
801050f8:	c3                   	ret    

801050f9 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
801050f9:	55                   	push   %ebp
801050fa:	89 e5                	mov    %esp,%ebp
801050fc:	57                   	push   %edi
801050fd:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801050fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105101:	8b 55 10             	mov    0x10(%ebp),%edx
80105104:	8b 45 0c             	mov    0xc(%ebp),%eax
80105107:	89 cb                	mov    %ecx,%ebx
80105109:	89 df                	mov    %ebx,%edi
8010510b:	89 d1                	mov    %edx,%ecx
8010510d:	fc                   	cld    
8010510e:	f3 ab                	rep stos %eax,%es:(%edi)
80105110:	89 ca                	mov    %ecx,%edx
80105112:	89 fb                	mov    %edi,%ebx
80105114:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105117:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
8010511a:	5b                   	pop    %ebx
8010511b:	5f                   	pop    %edi
8010511c:	5d                   	pop    %ebp
8010511d:	c3                   	ret    

8010511e <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
8010511e:	55                   	push   %ebp
8010511f:	89 e5                	mov    %esp,%ebp
80105121:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
80105124:	8b 45 08             	mov    0x8(%ebp),%eax
80105127:	83 e0 03             	and    $0x3,%eax
8010512a:	85 c0                	test   %eax,%eax
8010512c:	75 49                	jne    80105177 <memset+0x59>
8010512e:	8b 45 10             	mov    0x10(%ebp),%eax
80105131:	83 e0 03             	and    $0x3,%eax
80105134:	85 c0                	test   %eax,%eax
80105136:	75 3f                	jne    80105177 <memset+0x59>
    c &= 0xFF;
80105138:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
8010513f:	8b 45 10             	mov    0x10(%ebp),%eax
80105142:	c1 e8 02             	shr    $0x2,%eax
80105145:	89 c2                	mov    %eax,%edx
80105147:	8b 45 0c             	mov    0xc(%ebp),%eax
8010514a:	c1 e0 18             	shl    $0x18,%eax
8010514d:	89 c1                	mov    %eax,%ecx
8010514f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105152:	c1 e0 10             	shl    $0x10,%eax
80105155:	09 c1                	or     %eax,%ecx
80105157:	8b 45 0c             	mov    0xc(%ebp),%eax
8010515a:	c1 e0 08             	shl    $0x8,%eax
8010515d:	09 c8                	or     %ecx,%eax
8010515f:	0b 45 0c             	or     0xc(%ebp),%eax
80105162:	89 54 24 08          	mov    %edx,0x8(%esp)
80105166:	89 44 24 04          	mov    %eax,0x4(%esp)
8010516a:	8b 45 08             	mov    0x8(%ebp),%eax
8010516d:	89 04 24             	mov    %eax,(%esp)
80105170:	e8 84 ff ff ff       	call   801050f9 <stosl>
80105175:	eb 19                	jmp    80105190 <memset+0x72>
  } else
    stosb(dst, c, n);
80105177:	8b 45 10             	mov    0x10(%ebp),%eax
8010517a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010517e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105181:	89 44 24 04          	mov    %eax,0x4(%esp)
80105185:	8b 45 08             	mov    0x8(%ebp),%eax
80105188:	89 04 24             	mov    %eax,(%esp)
8010518b:	e8 44 ff ff ff       	call   801050d4 <stosb>
  return dst;
80105190:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105193:	c9                   	leave  
80105194:	c3                   	ret    

80105195 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105195:	55                   	push   %ebp
80105196:	89 e5                	mov    %esp,%ebp
80105198:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
8010519b:	8b 45 08             	mov    0x8(%ebp),%eax
8010519e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801051a1:	8b 45 0c             	mov    0xc(%ebp),%eax
801051a4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801051a7:	eb 2a                	jmp    801051d3 <memcmp+0x3e>
    if(*s1 != *s2)
801051a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051ac:	8a 10                	mov    (%eax),%dl
801051ae:	8b 45 f8             	mov    -0x8(%ebp),%eax
801051b1:	8a 00                	mov    (%eax),%al
801051b3:	38 c2                	cmp    %al,%dl
801051b5:	74 16                	je     801051cd <memcmp+0x38>
      return *s1 - *s2;
801051b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051ba:	8a 00                	mov    (%eax),%al
801051bc:	0f b6 d0             	movzbl %al,%edx
801051bf:	8b 45 f8             	mov    -0x8(%ebp),%eax
801051c2:	8a 00                	mov    (%eax),%al
801051c4:	0f b6 c0             	movzbl %al,%eax
801051c7:	29 c2                	sub    %eax,%edx
801051c9:	89 d0                	mov    %edx,%eax
801051cb:	eb 18                	jmp    801051e5 <memcmp+0x50>
    s1++, s2++;
801051cd:	ff 45 fc             	incl   -0x4(%ebp)
801051d0:	ff 45 f8             	incl   -0x8(%ebp)
{
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
801051d3:	8b 45 10             	mov    0x10(%ebp),%eax
801051d6:	8d 50 ff             	lea    -0x1(%eax),%edx
801051d9:	89 55 10             	mov    %edx,0x10(%ebp)
801051dc:	85 c0                	test   %eax,%eax
801051de:	75 c9                	jne    801051a9 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
801051e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801051e5:	c9                   	leave  
801051e6:	c3                   	ret    

801051e7 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801051e7:	55                   	push   %ebp
801051e8:	89 e5                	mov    %esp,%ebp
801051ea:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801051ed:	8b 45 0c             	mov    0xc(%ebp),%eax
801051f0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801051f3:	8b 45 08             	mov    0x8(%ebp),%eax
801051f6:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801051f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051fc:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801051ff:	73 3a                	jae    8010523b <memmove+0x54>
80105201:	8b 45 10             	mov    0x10(%ebp),%eax
80105204:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105207:	01 d0                	add    %edx,%eax
80105209:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010520c:	76 2d                	jbe    8010523b <memmove+0x54>
    s += n;
8010520e:	8b 45 10             	mov    0x10(%ebp),%eax
80105211:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105214:	8b 45 10             	mov    0x10(%ebp),%eax
80105217:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
8010521a:	eb 10                	jmp    8010522c <memmove+0x45>
      *--d = *--s;
8010521c:	ff 4d f8             	decl   -0x8(%ebp)
8010521f:	ff 4d fc             	decl   -0x4(%ebp)
80105222:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105225:	8a 10                	mov    (%eax),%dl
80105227:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010522a:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
8010522c:	8b 45 10             	mov    0x10(%ebp),%eax
8010522f:	8d 50 ff             	lea    -0x1(%eax),%edx
80105232:	89 55 10             	mov    %edx,0x10(%ebp)
80105235:	85 c0                	test   %eax,%eax
80105237:	75 e3                	jne    8010521c <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105239:	eb 25                	jmp    80105260 <memmove+0x79>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
8010523b:	eb 16                	jmp    80105253 <memmove+0x6c>
      *d++ = *s++;
8010523d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105240:	8d 50 01             	lea    0x1(%eax),%edx
80105243:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105246:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105249:	8d 4a 01             	lea    0x1(%edx),%ecx
8010524c:	89 4d fc             	mov    %ecx,-0x4(%ebp)
8010524f:	8a 12                	mov    (%edx),%dl
80105251:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105253:	8b 45 10             	mov    0x10(%ebp),%eax
80105256:	8d 50 ff             	lea    -0x1(%eax),%edx
80105259:	89 55 10             	mov    %edx,0x10(%ebp)
8010525c:	85 c0                	test   %eax,%eax
8010525e:	75 dd                	jne    8010523d <memmove+0x56>
      *d++ = *s++;

  return dst;
80105260:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105263:	c9                   	leave  
80105264:	c3                   	ret    

80105265 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105265:	55                   	push   %ebp
80105266:	89 e5                	mov    %esp,%ebp
80105268:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
8010526b:	8b 45 10             	mov    0x10(%ebp),%eax
8010526e:	89 44 24 08          	mov    %eax,0x8(%esp)
80105272:	8b 45 0c             	mov    0xc(%ebp),%eax
80105275:	89 44 24 04          	mov    %eax,0x4(%esp)
80105279:	8b 45 08             	mov    0x8(%ebp),%eax
8010527c:	89 04 24             	mov    %eax,(%esp)
8010527f:	e8 63 ff ff ff       	call   801051e7 <memmove>
}
80105284:	c9                   	leave  
80105285:	c3                   	ret    

80105286 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105286:	55                   	push   %ebp
80105287:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105289:	eb 09                	jmp    80105294 <strncmp+0xe>
    n--, p++, q++;
8010528b:	ff 4d 10             	decl   0x10(%ebp)
8010528e:	ff 45 08             	incl   0x8(%ebp)
80105291:	ff 45 0c             	incl   0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105294:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105298:	74 17                	je     801052b1 <strncmp+0x2b>
8010529a:	8b 45 08             	mov    0x8(%ebp),%eax
8010529d:	8a 00                	mov    (%eax),%al
8010529f:	84 c0                	test   %al,%al
801052a1:	74 0e                	je     801052b1 <strncmp+0x2b>
801052a3:	8b 45 08             	mov    0x8(%ebp),%eax
801052a6:	8a 10                	mov    (%eax),%dl
801052a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801052ab:	8a 00                	mov    (%eax),%al
801052ad:	38 c2                	cmp    %al,%dl
801052af:	74 da                	je     8010528b <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
801052b1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801052b5:	75 07                	jne    801052be <strncmp+0x38>
    return 0;
801052b7:	b8 00 00 00 00       	mov    $0x0,%eax
801052bc:	eb 14                	jmp    801052d2 <strncmp+0x4c>
  return (uchar)*p - (uchar)*q;
801052be:	8b 45 08             	mov    0x8(%ebp),%eax
801052c1:	8a 00                	mov    (%eax),%al
801052c3:	0f b6 d0             	movzbl %al,%edx
801052c6:	8b 45 0c             	mov    0xc(%ebp),%eax
801052c9:	8a 00                	mov    (%eax),%al
801052cb:	0f b6 c0             	movzbl %al,%eax
801052ce:	29 c2                	sub    %eax,%edx
801052d0:	89 d0                	mov    %edx,%eax
}
801052d2:	5d                   	pop    %ebp
801052d3:	c3                   	ret    

801052d4 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801052d4:	55                   	push   %ebp
801052d5:	89 e5                	mov    %esp,%ebp
801052d7:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801052da:	8b 45 08             	mov    0x8(%ebp),%eax
801052dd:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801052e0:	90                   	nop
801052e1:	8b 45 10             	mov    0x10(%ebp),%eax
801052e4:	8d 50 ff             	lea    -0x1(%eax),%edx
801052e7:	89 55 10             	mov    %edx,0x10(%ebp)
801052ea:	85 c0                	test   %eax,%eax
801052ec:	7e 1c                	jle    8010530a <strncpy+0x36>
801052ee:	8b 45 08             	mov    0x8(%ebp),%eax
801052f1:	8d 50 01             	lea    0x1(%eax),%edx
801052f4:	89 55 08             	mov    %edx,0x8(%ebp)
801052f7:	8b 55 0c             	mov    0xc(%ebp),%edx
801052fa:	8d 4a 01             	lea    0x1(%edx),%ecx
801052fd:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105300:	8a 12                	mov    (%edx),%dl
80105302:	88 10                	mov    %dl,(%eax)
80105304:	8a 00                	mov    (%eax),%al
80105306:	84 c0                	test   %al,%al
80105308:	75 d7                	jne    801052e1 <strncpy+0xd>
    ;
  while(n-- > 0)
8010530a:	eb 0c                	jmp    80105318 <strncpy+0x44>
    *s++ = 0;
8010530c:	8b 45 08             	mov    0x8(%ebp),%eax
8010530f:	8d 50 01             	lea    0x1(%eax),%edx
80105312:	89 55 08             	mov    %edx,0x8(%ebp)
80105315:	c6 00 00             	movb   $0x0,(%eax)
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105318:	8b 45 10             	mov    0x10(%ebp),%eax
8010531b:	8d 50 ff             	lea    -0x1(%eax),%edx
8010531e:	89 55 10             	mov    %edx,0x10(%ebp)
80105321:	85 c0                	test   %eax,%eax
80105323:	7f e7                	jg     8010530c <strncpy+0x38>
    *s++ = 0;
  return os;
80105325:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105328:	c9                   	leave  
80105329:	c3                   	ret    

8010532a <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
8010532a:	55                   	push   %ebp
8010532b:	89 e5                	mov    %esp,%ebp
8010532d:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105330:	8b 45 08             	mov    0x8(%ebp),%eax
80105333:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105336:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010533a:	7f 05                	jg     80105341 <safestrcpy+0x17>
    return os;
8010533c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010533f:	eb 2e                	jmp    8010536f <safestrcpy+0x45>
  while(--n > 0 && (*s++ = *t++) != 0)
80105341:	ff 4d 10             	decl   0x10(%ebp)
80105344:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105348:	7e 1c                	jle    80105366 <safestrcpy+0x3c>
8010534a:	8b 45 08             	mov    0x8(%ebp),%eax
8010534d:	8d 50 01             	lea    0x1(%eax),%edx
80105350:	89 55 08             	mov    %edx,0x8(%ebp)
80105353:	8b 55 0c             	mov    0xc(%ebp),%edx
80105356:	8d 4a 01             	lea    0x1(%edx),%ecx
80105359:	89 4d 0c             	mov    %ecx,0xc(%ebp)
8010535c:	8a 12                	mov    (%edx),%dl
8010535e:	88 10                	mov    %dl,(%eax)
80105360:	8a 00                	mov    (%eax),%al
80105362:	84 c0                	test   %al,%al
80105364:	75 db                	jne    80105341 <safestrcpy+0x17>
    ;
  *s = 0;
80105366:	8b 45 08             	mov    0x8(%ebp),%eax
80105369:	c6 00 00             	movb   $0x0,(%eax)
  return os;
8010536c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010536f:	c9                   	leave  
80105370:	c3                   	ret    

80105371 <strlen>:

int
strlen(const char *s)
{
80105371:	55                   	push   %ebp
80105372:	89 e5                	mov    %esp,%ebp
80105374:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105377:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010537e:	eb 03                	jmp    80105383 <strlen+0x12>
80105380:	ff 45 fc             	incl   -0x4(%ebp)
80105383:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105386:	8b 45 08             	mov    0x8(%ebp),%eax
80105389:	01 d0                	add    %edx,%eax
8010538b:	8a 00                	mov    (%eax),%al
8010538d:	84 c0                	test   %al,%al
8010538f:	75 ef                	jne    80105380 <strlen+0xf>
    ;
  return n;
80105391:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105394:	c9                   	leave  
80105395:	c3                   	ret    
	...

80105398 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105398:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
8010539c:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801053a0:	55                   	push   %ebp
  pushl %ebx
801053a1:	53                   	push   %ebx
  pushl %esi
801053a2:	56                   	push   %esi
  pushl %edi
801053a3:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801053a4:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801053a6:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801053a8:	5f                   	pop    %edi
  popl %esi
801053a9:	5e                   	pop    %esi
  popl %ebx
801053aa:	5b                   	pop    %ebx
  popl %ebp
801053ab:	5d                   	pop    %ebp
  ret
801053ac:	c3                   	ret    
801053ad:	00 00                	add    %al,(%eax)
	...

801053b0 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801053b0:	55                   	push   %ebp
801053b1:	89 e5                	mov    %esp,%ebp
801053b3:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
801053b6:	e8 e4 ee ff ff       	call   8010429f <myproc>
801053bb:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
801053be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053c1:	8b 00                	mov    (%eax),%eax
801053c3:	3b 45 08             	cmp    0x8(%ebp),%eax
801053c6:	76 0f                	jbe    801053d7 <fetchint+0x27>
801053c8:	8b 45 08             	mov    0x8(%ebp),%eax
801053cb:	8d 50 04             	lea    0x4(%eax),%edx
801053ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053d1:	8b 00                	mov    (%eax),%eax
801053d3:	39 c2                	cmp    %eax,%edx
801053d5:	76 07                	jbe    801053de <fetchint+0x2e>
    return -1;
801053d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053dc:	eb 0f                	jmp    801053ed <fetchint+0x3d>
  *ip = *(int*)(addr);
801053de:	8b 45 08             	mov    0x8(%ebp),%eax
801053e1:	8b 10                	mov    (%eax),%edx
801053e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801053e6:	89 10                	mov    %edx,(%eax)
  return 0;
801053e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801053ed:	c9                   	leave  
801053ee:	c3                   	ret    

801053ef <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801053ef:	55                   	push   %ebp
801053f0:	89 e5                	mov    %esp,%ebp
801053f2:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
801053f5:	e8 a5 ee ff ff       	call   8010429f <myproc>
801053fa:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
801053fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105400:	8b 00                	mov    (%eax),%eax
80105402:	3b 45 08             	cmp    0x8(%ebp),%eax
80105405:	77 07                	ja     8010540e <fetchstr+0x1f>
    return -1;
80105407:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010540c:	eb 41                	jmp    8010544f <fetchstr+0x60>
  *pp = (char*)addr;
8010540e:	8b 55 08             	mov    0x8(%ebp),%edx
80105411:	8b 45 0c             	mov    0xc(%ebp),%eax
80105414:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80105416:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105419:	8b 00                	mov    (%eax),%eax
8010541b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
8010541e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105421:	8b 00                	mov    (%eax),%eax
80105423:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105426:	eb 1a                	jmp    80105442 <fetchstr+0x53>
    if(*s == 0)
80105428:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010542b:	8a 00                	mov    (%eax),%al
8010542d:	84 c0                	test   %al,%al
8010542f:	75 0e                	jne    8010543f <fetchstr+0x50>
      return s - *pp;
80105431:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105434:	8b 45 0c             	mov    0xc(%ebp),%eax
80105437:	8b 00                	mov    (%eax),%eax
80105439:	29 c2                	sub    %eax,%edx
8010543b:	89 d0                	mov    %edx,%eax
8010543d:	eb 10                	jmp    8010544f <fetchstr+0x60>

  if(addr >= curproc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)curproc->sz;
  for(s = *pp; s < ep; s++){
8010543f:	ff 45 f4             	incl   -0xc(%ebp)
80105442:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105445:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80105448:	72 de                	jb     80105428 <fetchstr+0x39>
    if(*s == 0)
      return s - *pp;
  }
  return -1;
8010544a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010544f:	c9                   	leave  
80105450:	c3                   	ret    

80105451 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105451:	55                   	push   %ebp
80105452:	89 e5                	mov    %esp,%ebp
80105454:	83 ec 18             	sub    $0x18,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105457:	e8 43 ee ff ff       	call   8010429f <myproc>
8010545c:	8b 40 18             	mov    0x18(%eax),%eax
8010545f:	8b 50 44             	mov    0x44(%eax),%edx
80105462:	8b 45 08             	mov    0x8(%ebp),%eax
80105465:	c1 e0 02             	shl    $0x2,%eax
80105468:	01 d0                	add    %edx,%eax
8010546a:	8d 50 04             	lea    0x4(%eax),%edx
8010546d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105470:	89 44 24 04          	mov    %eax,0x4(%esp)
80105474:	89 14 24             	mov    %edx,(%esp)
80105477:	e8 34 ff ff ff       	call   801053b0 <fetchint>
}
8010547c:	c9                   	leave  
8010547d:	c3                   	ret    

8010547e <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
8010547e:	55                   	push   %ebp
8010547f:	89 e5                	mov    %esp,%ebp
80105481:	83 ec 28             	sub    $0x28,%esp
  int i;
  struct proc *curproc = myproc();
80105484:	e8 16 ee ff ff       	call   8010429f <myproc>
80105489:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
8010548c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010548f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105493:	8b 45 08             	mov    0x8(%ebp),%eax
80105496:	89 04 24             	mov    %eax,(%esp)
80105499:	e8 b3 ff ff ff       	call   80105451 <argint>
8010549e:	85 c0                	test   %eax,%eax
801054a0:	79 07                	jns    801054a9 <argptr+0x2b>
    return -1;
801054a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054a7:	eb 3d                	jmp    801054e6 <argptr+0x68>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
801054a9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054ad:	78 21                	js     801054d0 <argptr+0x52>
801054af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054b2:	89 c2                	mov    %eax,%edx
801054b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054b7:	8b 00                	mov    (%eax),%eax
801054b9:	39 c2                	cmp    %eax,%edx
801054bb:	73 13                	jae    801054d0 <argptr+0x52>
801054bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054c0:	89 c2                	mov    %eax,%edx
801054c2:	8b 45 10             	mov    0x10(%ebp),%eax
801054c5:	01 c2                	add    %eax,%edx
801054c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054ca:	8b 00                	mov    (%eax),%eax
801054cc:	39 c2                	cmp    %eax,%edx
801054ce:	76 07                	jbe    801054d7 <argptr+0x59>
    return -1;
801054d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054d5:	eb 0f                	jmp    801054e6 <argptr+0x68>
  *pp = (char*)i;
801054d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054da:	89 c2                	mov    %eax,%edx
801054dc:	8b 45 0c             	mov    0xc(%ebp),%eax
801054df:	89 10                	mov    %edx,(%eax)
  return 0;
801054e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801054e6:	c9                   	leave  
801054e7:	c3                   	ret    

801054e8 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801054e8:	55                   	push   %ebp
801054e9:	89 e5                	mov    %esp,%ebp
801054eb:	83 ec 28             	sub    $0x28,%esp
  int addr;
  if(argint(n, &addr) < 0)
801054ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
801054f1:	89 44 24 04          	mov    %eax,0x4(%esp)
801054f5:	8b 45 08             	mov    0x8(%ebp),%eax
801054f8:	89 04 24             	mov    %eax,(%esp)
801054fb:	e8 51 ff ff ff       	call   80105451 <argint>
80105500:	85 c0                	test   %eax,%eax
80105502:	79 07                	jns    8010550b <argstr+0x23>
    return -1;
80105504:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105509:	eb 12                	jmp    8010551d <argstr+0x35>
  return fetchstr(addr, pp);
8010550b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010550e:	8b 55 0c             	mov    0xc(%ebp),%edx
80105511:	89 54 24 04          	mov    %edx,0x4(%esp)
80105515:	89 04 24             	mov    %eax,(%esp)
80105518:	e8 d2 fe ff ff       	call   801053ef <fetchstr>
}
8010551d:	c9                   	leave  
8010551e:	c3                   	ret    

8010551f <syscall>:
[SYS_set_curr_proc] sys_set_curr_proc,
};

void
syscall(void)
{
8010551f:	55                   	push   %ebp
80105520:	89 e5                	mov    %esp,%ebp
80105522:	53                   	push   %ebx
80105523:	83 ec 24             	sub    $0x24,%esp
  int num;
  struct proc *curproc = myproc();
80105526:	e8 74 ed ff ff       	call   8010429f <myproc>
8010552b:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
8010552e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105531:	8b 40 18             	mov    0x18(%eax),%eax
80105534:	8b 40 1c             	mov    0x1c(%eax),%eax
80105537:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
8010553a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010553e:	7e 2d                	jle    8010556d <syscall+0x4e>
80105540:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105543:	83 f8 24             	cmp    $0x24,%eax
80105546:	77 25                	ja     8010556d <syscall+0x4e>
80105548:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010554b:	8b 04 85 20 b0 10 80 	mov    -0x7fef4fe0(,%eax,4),%eax
80105552:	85 c0                	test   %eax,%eax
80105554:	74 17                	je     8010556d <syscall+0x4e>
    curproc->tf->eax = syscalls[num]();
80105556:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105559:	8b 58 18             	mov    0x18(%eax),%ebx
8010555c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010555f:	8b 04 85 20 b0 10 80 	mov    -0x7fef4fe0(,%eax,4),%eax
80105566:	ff d0                	call   *%eax
80105568:	89 43 1c             	mov    %eax,0x1c(%ebx)
8010556b:	eb 34                	jmp    801055a1 <syscall+0x82>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
8010556d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105570:	8d 48 6c             	lea    0x6c(%eax),%ecx

  num = curproc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    curproc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105573:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105576:	8b 40 10             	mov    0x10(%eax),%eax
80105579:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010557c:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105580:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105584:	89 44 24 04          	mov    %eax,0x4(%esp)
80105588:	c7 04 24 1c 8d 10 80 	movl   $0x80108d1c,(%esp)
8010558f:	e8 2d ae ff ff       	call   801003c1 <cprintf>
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
80105594:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105597:	8b 40 18             	mov    0x18(%eax),%eax
8010559a:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801055a1:	83 c4 24             	add    $0x24,%esp
801055a4:	5b                   	pop    %ebx
801055a5:	5d                   	pop    %ebp
801055a6:	c3                   	ret    
	...

801055a8 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801055a8:	55                   	push   %ebp
801055a9:	89 e5                	mov    %esp,%ebp
801055ab:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801055ae:	8d 45 f0             	lea    -0x10(%ebp),%eax
801055b1:	89 44 24 04          	mov    %eax,0x4(%esp)
801055b5:	8b 45 08             	mov    0x8(%ebp),%eax
801055b8:	89 04 24             	mov    %eax,(%esp)
801055bb:	e8 91 fe ff ff       	call   80105451 <argint>
801055c0:	85 c0                	test   %eax,%eax
801055c2:	79 07                	jns    801055cb <argfd+0x23>
    return -1;
801055c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055c9:	eb 4f                	jmp    8010561a <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
801055cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055ce:	85 c0                	test   %eax,%eax
801055d0:	78 20                	js     801055f2 <argfd+0x4a>
801055d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055d5:	83 f8 0f             	cmp    $0xf,%eax
801055d8:	7f 18                	jg     801055f2 <argfd+0x4a>
801055da:	e8 c0 ec ff ff       	call   8010429f <myproc>
801055df:	8b 55 f0             	mov    -0x10(%ebp),%edx
801055e2:	83 c2 08             	add    $0x8,%edx
801055e5:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801055e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801055ec:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801055f0:	75 07                	jne    801055f9 <argfd+0x51>
    return -1;
801055f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055f7:	eb 21                	jmp    8010561a <argfd+0x72>
  if(pfd)
801055f9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801055fd:	74 08                	je     80105607 <argfd+0x5f>
    *pfd = fd;
801055ff:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105602:	8b 45 0c             	mov    0xc(%ebp),%eax
80105605:	89 10                	mov    %edx,(%eax)
  if(pf)
80105607:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010560b:	74 08                	je     80105615 <argfd+0x6d>
    *pf = f;
8010560d:	8b 45 10             	mov    0x10(%ebp),%eax
80105610:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105613:	89 10                	mov    %edx,(%eax)
  return 0;
80105615:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010561a:	c9                   	leave  
8010561b:	c3                   	ret    

8010561c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
8010561c:	55                   	push   %ebp
8010561d:	89 e5                	mov    %esp,%ebp
8010561f:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105622:	e8 78 ec ff ff       	call   8010429f <myproc>
80105627:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
8010562a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105631:	eb 29                	jmp    8010565c <fdalloc+0x40>
    if(curproc->ofile[fd] == 0){
80105633:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105636:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105639:	83 c2 08             	add    $0x8,%edx
8010563c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105640:	85 c0                	test   %eax,%eax
80105642:	75 15                	jne    80105659 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80105644:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105647:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010564a:	8d 4a 08             	lea    0x8(%edx),%ecx
8010564d:	8b 55 08             	mov    0x8(%ebp),%edx
80105650:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105654:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105657:	eb 0e                	jmp    80105667 <fdalloc+0x4b>
fdalloc(struct file *f)
{
  int fd;
  struct proc *curproc = myproc();

  for(fd = 0; fd < NOFILE; fd++){
80105659:	ff 45 f4             	incl   -0xc(%ebp)
8010565c:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105660:	7e d1                	jle    80105633 <fdalloc+0x17>
    if(curproc->ofile[fd] == 0){
      curproc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105662:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105667:	c9                   	leave  
80105668:	c3                   	ret    

80105669 <sys_dup>:

int
sys_dup(void)
{
80105669:	55                   	push   %ebp
8010566a:	89 e5                	mov    %esp,%ebp
8010566c:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
8010566f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105672:	89 44 24 08          	mov    %eax,0x8(%esp)
80105676:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010567d:	00 
8010567e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105685:	e8 1e ff ff ff       	call   801055a8 <argfd>
8010568a:	85 c0                	test   %eax,%eax
8010568c:	79 07                	jns    80105695 <sys_dup+0x2c>
    return -1;
8010568e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105693:	eb 29                	jmp    801056be <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105695:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105698:	89 04 24             	mov    %eax,(%esp)
8010569b:	e8 7c ff ff ff       	call   8010561c <fdalloc>
801056a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801056a3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056a7:	79 07                	jns    801056b0 <sys_dup+0x47>
    return -1;
801056a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056ae:	eb 0e                	jmp    801056be <sys_dup+0x55>
  filedup(f);
801056b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056b3:	89 04 24             	mov    %eax,(%esp)
801056b6:	e8 91 ba ff ff       	call   8010114c <filedup>
  return fd;
801056bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801056be:	c9                   	leave  
801056bf:	c3                   	ret    

801056c0 <sys_read>:

int
sys_read(void)
{
801056c0:	55                   	push   %ebp
801056c1:	89 e5                	mov    %esp,%ebp
801056c3:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801056c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
801056c9:	89 44 24 08          	mov    %eax,0x8(%esp)
801056cd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801056d4:	00 
801056d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801056dc:	e8 c7 fe ff ff       	call   801055a8 <argfd>
801056e1:	85 c0                	test   %eax,%eax
801056e3:	78 35                	js     8010571a <sys_read+0x5a>
801056e5:	8d 45 f0             	lea    -0x10(%ebp),%eax
801056e8:	89 44 24 04          	mov    %eax,0x4(%esp)
801056ec:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801056f3:	e8 59 fd ff ff       	call   80105451 <argint>
801056f8:	85 c0                	test   %eax,%eax
801056fa:	78 1e                	js     8010571a <sys_read+0x5a>
801056fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056ff:	89 44 24 08          	mov    %eax,0x8(%esp)
80105703:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105706:	89 44 24 04          	mov    %eax,0x4(%esp)
8010570a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105711:	e8 68 fd ff ff       	call   8010547e <argptr>
80105716:	85 c0                	test   %eax,%eax
80105718:	79 07                	jns    80105721 <sys_read+0x61>
    return -1;
8010571a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010571f:	eb 19                	jmp    8010573a <sys_read+0x7a>
  return fileread(f, p, n);
80105721:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105724:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105727:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010572a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010572e:	89 54 24 04          	mov    %edx,0x4(%esp)
80105732:	89 04 24             	mov    %eax,(%esp)
80105735:	e8 73 bb ff ff       	call   801012ad <fileread>
}
8010573a:	c9                   	leave  
8010573b:	c3                   	ret    

8010573c <sys_write>:

int
sys_write(void)
{
8010573c:	55                   	push   %ebp
8010573d:	89 e5                	mov    %esp,%ebp
8010573f:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105742:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105745:	89 44 24 08          	mov    %eax,0x8(%esp)
80105749:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105750:	00 
80105751:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105758:	e8 4b fe ff ff       	call   801055a8 <argfd>
8010575d:	85 c0                	test   %eax,%eax
8010575f:	78 35                	js     80105796 <sys_write+0x5a>
80105761:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105764:	89 44 24 04          	mov    %eax,0x4(%esp)
80105768:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010576f:	e8 dd fc ff ff       	call   80105451 <argint>
80105774:	85 c0                	test   %eax,%eax
80105776:	78 1e                	js     80105796 <sys_write+0x5a>
80105778:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010577b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010577f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105782:	89 44 24 04          	mov    %eax,0x4(%esp)
80105786:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010578d:	e8 ec fc ff ff       	call   8010547e <argptr>
80105792:	85 c0                	test   %eax,%eax
80105794:	79 07                	jns    8010579d <sys_write+0x61>
    return -1;
80105796:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010579b:	eb 19                	jmp    801057b6 <sys_write+0x7a>
  return filewrite(f, p, n);
8010579d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801057a0:	8b 55 ec             	mov    -0x14(%ebp),%edx
801057a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057a6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801057aa:	89 54 24 04          	mov    %edx,0x4(%esp)
801057ae:	89 04 24             	mov    %eax,(%esp)
801057b1:	e8 b2 bb ff ff       	call   80101368 <filewrite>
}
801057b6:	c9                   	leave  
801057b7:	c3                   	ret    

801057b8 <sys_close>:

int
sys_close(void)
{
801057b8:	55                   	push   %ebp
801057b9:	89 e5                	mov    %esp,%ebp
801057bb:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
801057be:	8d 45 f0             	lea    -0x10(%ebp),%eax
801057c1:	89 44 24 08          	mov    %eax,0x8(%esp)
801057c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
801057c8:	89 44 24 04          	mov    %eax,0x4(%esp)
801057cc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801057d3:	e8 d0 fd ff ff       	call   801055a8 <argfd>
801057d8:	85 c0                	test   %eax,%eax
801057da:	79 07                	jns    801057e3 <sys_close+0x2b>
    return -1;
801057dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057e1:	eb 23                	jmp    80105806 <sys_close+0x4e>
  myproc()->ofile[fd] = 0;
801057e3:	e8 b7 ea ff ff       	call   8010429f <myproc>
801057e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801057eb:	83 c2 08             	add    $0x8,%edx
801057ee:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801057f5:	00 
  fileclose(f);
801057f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057f9:	89 04 24             	mov    %eax,(%esp)
801057fc:	e8 93 b9 ff ff       	call   80101194 <fileclose>
  return 0;
80105801:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105806:	c9                   	leave  
80105807:	c3                   	ret    

80105808 <sys_fstat>:

int
sys_fstat(void)
{
80105808:	55                   	push   %ebp
80105809:	89 e5                	mov    %esp,%ebp
8010580b:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010580e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105811:	89 44 24 08          	mov    %eax,0x8(%esp)
80105815:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010581c:	00 
8010581d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105824:	e8 7f fd ff ff       	call   801055a8 <argfd>
80105829:	85 c0                	test   %eax,%eax
8010582b:	78 1f                	js     8010584c <sys_fstat+0x44>
8010582d:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105834:	00 
80105835:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105838:	89 44 24 04          	mov    %eax,0x4(%esp)
8010583c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105843:	e8 36 fc ff ff       	call   8010547e <argptr>
80105848:	85 c0                	test   %eax,%eax
8010584a:	79 07                	jns    80105853 <sys_fstat+0x4b>
    return -1;
8010584c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105851:	eb 12                	jmp    80105865 <sys_fstat+0x5d>
  return filestat(f, st);
80105853:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105856:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105859:	89 54 24 04          	mov    %edx,0x4(%esp)
8010585d:	89 04 24             	mov    %eax,(%esp)
80105860:	e8 f9 b9 ff ff       	call   8010125e <filestat>
}
80105865:	c9                   	leave  
80105866:	c3                   	ret    

80105867 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105867:	55                   	push   %ebp
80105868:	89 e5                	mov    %esp,%ebp
8010586a:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010586d:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105870:	89 44 24 04          	mov    %eax,0x4(%esp)
80105874:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010587b:	e8 68 fc ff ff       	call   801054e8 <argstr>
80105880:	85 c0                	test   %eax,%eax
80105882:	78 17                	js     8010589b <sys_link+0x34>
80105884:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105887:	89 44 24 04          	mov    %eax,0x4(%esp)
8010588b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105892:	e8 51 fc ff ff       	call   801054e8 <argstr>
80105897:	85 c0                	test   %eax,%eax
80105899:	79 0a                	jns    801058a5 <sys_link+0x3e>
    return -1;
8010589b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058a0:	e9 3d 01 00 00       	jmp    801059e2 <sys_link+0x17b>

  begin_op();
801058a5:	e8 fd dc ff ff       	call   801035a7 <begin_op>
  if((ip = namei(old)) == 0){
801058aa:	8b 45 d8             	mov    -0x28(%ebp),%eax
801058ad:	89 04 24             	mov    %eax,(%esp)
801058b0:	e8 1e cd ff ff       	call   801025d3 <namei>
801058b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058bc:	75 0f                	jne    801058cd <sys_link+0x66>
    end_op();
801058be:	e8 66 dd ff ff       	call   80103629 <end_op>
    return -1;
801058c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058c8:	e9 15 01 00 00       	jmp    801059e2 <sys_link+0x17b>
  }

  ilock(ip);
801058cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058d0:	89 04 24             	mov    %eax,(%esp)
801058d3:	e8 d6 c1 ff ff       	call   80101aae <ilock>
  if(ip->type == T_DIR){
801058d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058db:	8b 40 50             	mov    0x50(%eax),%eax
801058de:	66 83 f8 01          	cmp    $0x1,%ax
801058e2:	75 1a                	jne    801058fe <sys_link+0x97>
    iunlockput(ip);
801058e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058e7:	89 04 24             	mov    %eax,(%esp)
801058ea:	e8 be c3 ff ff       	call   80101cad <iunlockput>
    end_op();
801058ef:	e8 35 dd ff ff       	call   80103629 <end_op>
    return -1;
801058f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058f9:	e9 e4 00 00 00       	jmp    801059e2 <sys_link+0x17b>
  }

  ip->nlink++;
801058fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105901:	66 8b 40 56          	mov    0x56(%eax),%ax
80105905:	40                   	inc    %eax
80105906:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105909:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
8010590d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105910:	89 04 24             	mov    %eax,(%esp)
80105913:	e8 d3 bf ff ff       	call   801018eb <iupdate>
  iunlock(ip);
80105918:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010591b:	89 04 24             	mov    %eax,(%esp)
8010591e:	e8 95 c2 ff ff       	call   80101bb8 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105923:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105926:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105929:	89 54 24 04          	mov    %edx,0x4(%esp)
8010592d:	89 04 24             	mov    %eax,(%esp)
80105930:	e8 c0 cc ff ff       	call   801025f5 <nameiparent>
80105935:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105938:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010593c:	75 02                	jne    80105940 <sys_link+0xd9>
    goto bad;
8010593e:	eb 68                	jmp    801059a8 <sys_link+0x141>
  ilock(dp);
80105940:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105943:	89 04 24             	mov    %eax,(%esp)
80105946:	e8 63 c1 ff ff       	call   80101aae <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
8010594b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010594e:	8b 10                	mov    (%eax),%edx
80105950:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105953:	8b 00                	mov    (%eax),%eax
80105955:	39 c2                	cmp    %eax,%edx
80105957:	75 20                	jne    80105979 <sys_link+0x112>
80105959:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010595c:	8b 40 04             	mov    0x4(%eax),%eax
8010595f:	89 44 24 08          	mov    %eax,0x8(%esp)
80105963:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105966:	89 44 24 04          	mov    %eax,0x4(%esp)
8010596a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010596d:	89 04 24             	mov    %eax,(%esp)
80105970:	e8 ab c9 ff ff       	call   80102320 <dirlink>
80105975:	85 c0                	test   %eax,%eax
80105977:	79 0d                	jns    80105986 <sys_link+0x11f>
    iunlockput(dp);
80105979:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010597c:	89 04 24             	mov    %eax,(%esp)
8010597f:	e8 29 c3 ff ff       	call   80101cad <iunlockput>
    goto bad;
80105984:	eb 22                	jmp    801059a8 <sys_link+0x141>
  }
  iunlockput(dp);
80105986:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105989:	89 04 24             	mov    %eax,(%esp)
8010598c:	e8 1c c3 ff ff       	call   80101cad <iunlockput>
  iput(ip);
80105991:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105994:	89 04 24             	mov    %eax,(%esp)
80105997:	e8 60 c2 ff ff       	call   80101bfc <iput>

  end_op();
8010599c:	e8 88 dc ff ff       	call   80103629 <end_op>

  return 0;
801059a1:	b8 00 00 00 00       	mov    $0x0,%eax
801059a6:	eb 3a                	jmp    801059e2 <sys_link+0x17b>

bad:
  ilock(ip);
801059a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059ab:	89 04 24             	mov    %eax,(%esp)
801059ae:	e8 fb c0 ff ff       	call   80101aae <ilock>
  ip->nlink--;
801059b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059b6:	66 8b 40 56          	mov    0x56(%eax),%ax
801059ba:	48                   	dec    %eax
801059bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801059be:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
801059c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059c5:	89 04 24             	mov    %eax,(%esp)
801059c8:	e8 1e bf ff ff       	call   801018eb <iupdate>
  iunlockput(ip);
801059cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059d0:	89 04 24             	mov    %eax,(%esp)
801059d3:	e8 d5 c2 ff ff       	call   80101cad <iunlockput>
  end_op();
801059d8:	e8 4c dc ff ff       	call   80103629 <end_op>
  return -1;
801059dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801059e2:	c9                   	leave  
801059e3:	c3                   	ret    

801059e4 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801059e4:	55                   	push   %ebp
801059e5:	89 e5                	mov    %esp,%ebp
801059e7:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801059ea:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
801059f1:	eb 4a                	jmp    80105a3d <isdirempty+0x59>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801059f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059f6:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801059fd:	00 
801059fe:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a02:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105a05:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a09:	8b 45 08             	mov    0x8(%ebp),%eax
80105a0c:	89 04 24             	mov    %eax,(%esp)
80105a0f:	e8 31 c5 ff ff       	call   80101f45 <readi>
80105a14:	83 f8 10             	cmp    $0x10,%eax
80105a17:	74 0c                	je     80105a25 <isdirempty+0x41>
      panic("isdirempty: readi");
80105a19:	c7 04 24 38 8d 10 80 	movl   $0x80108d38,(%esp)
80105a20:	e8 2f ab ff ff       	call   80100554 <panic>
    if(de.inum != 0)
80105a25:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105a28:	66 85 c0             	test   %ax,%ax
80105a2b:	74 07                	je     80105a34 <isdirempty+0x50>
      return 0;
80105a2d:	b8 00 00 00 00       	mov    $0x0,%eax
80105a32:	eb 1b                	jmp    80105a4f <isdirempty+0x6b>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105a34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a37:	83 c0 10             	add    $0x10,%eax
80105a3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a3d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a40:	8b 45 08             	mov    0x8(%ebp),%eax
80105a43:	8b 40 58             	mov    0x58(%eax),%eax
80105a46:	39 c2                	cmp    %eax,%edx
80105a48:	72 a9                	jb     801059f3 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105a4a:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105a4f:	c9                   	leave  
80105a50:	c3                   	ret    

80105a51 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105a51:	55                   	push   %ebp
80105a52:	89 e5                	mov    %esp,%ebp
80105a54:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105a57:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105a5a:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a5e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105a65:	e8 7e fa ff ff       	call   801054e8 <argstr>
80105a6a:	85 c0                	test   %eax,%eax
80105a6c:	79 0a                	jns    80105a78 <sys_unlink+0x27>
    return -1;
80105a6e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a73:	e9 a9 01 00 00       	jmp    80105c21 <sys_unlink+0x1d0>

  begin_op();
80105a78:	e8 2a db ff ff       	call   801035a7 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105a7d:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105a80:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105a83:	89 54 24 04          	mov    %edx,0x4(%esp)
80105a87:	89 04 24             	mov    %eax,(%esp)
80105a8a:	e8 66 cb ff ff       	call   801025f5 <nameiparent>
80105a8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a92:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a96:	75 0f                	jne    80105aa7 <sys_unlink+0x56>
    end_op();
80105a98:	e8 8c db ff ff       	call   80103629 <end_op>
    return -1;
80105a9d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105aa2:	e9 7a 01 00 00       	jmp    80105c21 <sys_unlink+0x1d0>
  }

  ilock(dp);
80105aa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aaa:	89 04 24             	mov    %eax,(%esp)
80105aad:	e8 fc bf ff ff       	call   80101aae <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105ab2:	c7 44 24 04 4a 8d 10 	movl   $0x80108d4a,0x4(%esp)
80105ab9:	80 
80105aba:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105abd:	89 04 24             	mov    %eax,(%esp)
80105ac0:	e8 73 c7 ff ff       	call   80102238 <namecmp>
80105ac5:	85 c0                	test   %eax,%eax
80105ac7:	0f 84 3f 01 00 00    	je     80105c0c <sys_unlink+0x1bb>
80105acd:	c7 44 24 04 4c 8d 10 	movl   $0x80108d4c,0x4(%esp)
80105ad4:	80 
80105ad5:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105ad8:	89 04 24             	mov    %eax,(%esp)
80105adb:	e8 58 c7 ff ff       	call   80102238 <namecmp>
80105ae0:	85 c0                	test   %eax,%eax
80105ae2:	0f 84 24 01 00 00    	je     80105c0c <sys_unlink+0x1bb>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105ae8:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105aeb:	89 44 24 08          	mov    %eax,0x8(%esp)
80105aef:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105af2:	89 44 24 04          	mov    %eax,0x4(%esp)
80105af6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105af9:	89 04 24             	mov    %eax,(%esp)
80105afc:	e8 59 c7 ff ff       	call   8010225a <dirlookup>
80105b01:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b04:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b08:	75 05                	jne    80105b0f <sys_unlink+0xbe>
    goto bad;
80105b0a:	e9 fd 00 00 00       	jmp    80105c0c <sys_unlink+0x1bb>
  ilock(ip);
80105b0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b12:	89 04 24             	mov    %eax,(%esp)
80105b15:	e8 94 bf ff ff       	call   80101aae <ilock>

  if(ip->nlink < 1)
80105b1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b1d:	66 8b 40 56          	mov    0x56(%eax),%ax
80105b21:	66 85 c0             	test   %ax,%ax
80105b24:	7f 0c                	jg     80105b32 <sys_unlink+0xe1>
    panic("unlink: nlink < 1");
80105b26:	c7 04 24 4f 8d 10 80 	movl   $0x80108d4f,(%esp)
80105b2d:	e8 22 aa ff ff       	call   80100554 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105b32:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b35:	8b 40 50             	mov    0x50(%eax),%eax
80105b38:	66 83 f8 01          	cmp    $0x1,%ax
80105b3c:	75 1f                	jne    80105b5d <sys_unlink+0x10c>
80105b3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b41:	89 04 24             	mov    %eax,(%esp)
80105b44:	e8 9b fe ff ff       	call   801059e4 <isdirempty>
80105b49:	85 c0                	test   %eax,%eax
80105b4b:	75 10                	jne    80105b5d <sys_unlink+0x10c>
    iunlockput(ip);
80105b4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b50:	89 04 24             	mov    %eax,(%esp)
80105b53:	e8 55 c1 ff ff       	call   80101cad <iunlockput>
    goto bad;
80105b58:	e9 af 00 00 00       	jmp    80105c0c <sys_unlink+0x1bb>
  }

  memset(&de, 0, sizeof(de));
80105b5d:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105b64:	00 
80105b65:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105b6c:	00 
80105b6d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105b70:	89 04 24             	mov    %eax,(%esp)
80105b73:	e8 a6 f5 ff ff       	call   8010511e <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105b78:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105b7b:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105b82:	00 
80105b83:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b87:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105b8a:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b91:	89 04 24             	mov    %eax,(%esp)
80105b94:	e8 10 c5 ff ff       	call   801020a9 <writei>
80105b99:	83 f8 10             	cmp    $0x10,%eax
80105b9c:	74 0c                	je     80105baa <sys_unlink+0x159>
    panic("unlink: writei");
80105b9e:	c7 04 24 61 8d 10 80 	movl   $0x80108d61,(%esp)
80105ba5:	e8 aa a9 ff ff       	call   80100554 <panic>
  if(ip->type == T_DIR){
80105baa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bad:	8b 40 50             	mov    0x50(%eax),%eax
80105bb0:	66 83 f8 01          	cmp    $0x1,%ax
80105bb4:	75 1a                	jne    80105bd0 <sys_unlink+0x17f>
    dp->nlink--;
80105bb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bb9:	66 8b 40 56          	mov    0x56(%eax),%ax
80105bbd:	48                   	dec    %eax
80105bbe:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105bc1:	66 89 42 56          	mov    %ax,0x56(%edx)
    iupdate(dp);
80105bc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bc8:	89 04 24             	mov    %eax,(%esp)
80105bcb:	e8 1b bd ff ff       	call   801018eb <iupdate>
  }
  iunlockput(dp);
80105bd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bd3:	89 04 24             	mov    %eax,(%esp)
80105bd6:	e8 d2 c0 ff ff       	call   80101cad <iunlockput>

  ip->nlink--;
80105bdb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bde:	66 8b 40 56          	mov    0x56(%eax),%ax
80105be2:	48                   	dec    %eax
80105be3:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105be6:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
80105bea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bed:	89 04 24             	mov    %eax,(%esp)
80105bf0:	e8 f6 bc ff ff       	call   801018eb <iupdate>
  iunlockput(ip);
80105bf5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bf8:	89 04 24             	mov    %eax,(%esp)
80105bfb:	e8 ad c0 ff ff       	call   80101cad <iunlockput>

  end_op();
80105c00:	e8 24 da ff ff       	call   80103629 <end_op>

  return 0;
80105c05:	b8 00 00 00 00       	mov    $0x0,%eax
80105c0a:	eb 15                	jmp    80105c21 <sys_unlink+0x1d0>

bad:
  iunlockput(dp);
80105c0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c0f:	89 04 24             	mov    %eax,(%esp)
80105c12:	e8 96 c0 ff ff       	call   80101cad <iunlockput>
  end_op();
80105c17:	e8 0d da ff ff       	call   80103629 <end_op>
  return -1;
80105c1c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105c21:	c9                   	leave  
80105c22:	c3                   	ret    

80105c23 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105c23:	55                   	push   %ebp
80105c24:	89 e5                	mov    %esp,%ebp
80105c26:	83 ec 48             	sub    $0x48,%esp
80105c29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105c2c:	8b 55 10             	mov    0x10(%ebp),%edx
80105c2f:	8b 45 14             	mov    0x14(%ebp),%eax
80105c32:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105c36:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105c3a:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105c3e:	8d 45 de             	lea    -0x22(%ebp),%eax
80105c41:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c45:	8b 45 08             	mov    0x8(%ebp),%eax
80105c48:	89 04 24             	mov    %eax,(%esp)
80105c4b:	e8 a5 c9 ff ff       	call   801025f5 <nameiparent>
80105c50:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c53:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c57:	75 0a                	jne    80105c63 <create+0x40>
    return 0;
80105c59:	b8 00 00 00 00       	mov    $0x0,%eax
80105c5e:	e9 79 01 00 00       	jmp    80105ddc <create+0x1b9>
  ilock(dp);
80105c63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c66:	89 04 24             	mov    %eax,(%esp)
80105c69:	e8 40 be ff ff       	call   80101aae <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80105c6e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c71:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c75:	8d 45 de             	lea    -0x22(%ebp),%eax
80105c78:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c7f:	89 04 24             	mov    %eax,(%esp)
80105c82:	e8 d3 c5 ff ff       	call   8010225a <dirlookup>
80105c87:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c8a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c8e:	74 46                	je     80105cd6 <create+0xb3>
    iunlockput(dp);
80105c90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c93:	89 04 24             	mov    %eax,(%esp)
80105c96:	e8 12 c0 ff ff       	call   80101cad <iunlockput>
    ilock(ip);
80105c9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c9e:	89 04 24             	mov    %eax,(%esp)
80105ca1:	e8 08 be ff ff       	call   80101aae <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80105ca6:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105cab:	75 14                	jne    80105cc1 <create+0x9e>
80105cad:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cb0:	8b 40 50             	mov    0x50(%eax),%eax
80105cb3:	66 83 f8 02          	cmp    $0x2,%ax
80105cb7:	75 08                	jne    80105cc1 <create+0x9e>
      return ip;
80105cb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cbc:	e9 1b 01 00 00       	jmp    80105ddc <create+0x1b9>
    iunlockput(ip);
80105cc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cc4:	89 04 24             	mov    %eax,(%esp)
80105cc7:	e8 e1 bf ff ff       	call   80101cad <iunlockput>
    return 0;
80105ccc:	b8 00 00 00 00       	mov    $0x0,%eax
80105cd1:	e9 06 01 00 00       	jmp    80105ddc <create+0x1b9>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105cd6:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105cda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cdd:	8b 00                	mov    (%eax),%eax
80105cdf:	89 54 24 04          	mov    %edx,0x4(%esp)
80105ce3:	89 04 24             	mov    %eax,(%esp)
80105ce6:	e8 2e bb ff ff       	call   80101819 <ialloc>
80105ceb:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105cee:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105cf2:	75 0c                	jne    80105d00 <create+0xdd>
    panic("create: ialloc");
80105cf4:	c7 04 24 70 8d 10 80 	movl   $0x80108d70,(%esp)
80105cfb:	e8 54 a8 ff ff       	call   80100554 <panic>

  ilock(ip);
80105d00:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d03:	89 04 24             	mov    %eax,(%esp)
80105d06:	e8 a3 bd ff ff       	call   80101aae <ilock>
  ip->major = major;
80105d0b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105d0e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80105d11:	66 89 42 52          	mov    %ax,0x52(%edx)
  ip->minor = minor;
80105d15:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105d18:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105d1b:	66 89 42 54          	mov    %ax,0x54(%edx)
  ip->nlink = 1;
80105d1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d22:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105d28:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d2b:	89 04 24             	mov    %eax,(%esp)
80105d2e:	e8 b8 bb ff ff       	call   801018eb <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80105d33:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105d38:	75 68                	jne    80105da2 <create+0x17f>
    dp->nlink++;  // for ".."
80105d3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d3d:	66 8b 40 56          	mov    0x56(%eax),%ax
80105d41:	40                   	inc    %eax
80105d42:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105d45:	66 89 42 56          	mov    %ax,0x56(%edx)
    iupdate(dp);
80105d49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d4c:	89 04 24             	mov    %eax,(%esp)
80105d4f:	e8 97 bb ff ff       	call   801018eb <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105d54:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d57:	8b 40 04             	mov    0x4(%eax),%eax
80105d5a:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d5e:	c7 44 24 04 4a 8d 10 	movl   $0x80108d4a,0x4(%esp)
80105d65:	80 
80105d66:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d69:	89 04 24             	mov    %eax,(%esp)
80105d6c:	e8 af c5 ff ff       	call   80102320 <dirlink>
80105d71:	85 c0                	test   %eax,%eax
80105d73:	78 21                	js     80105d96 <create+0x173>
80105d75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d78:	8b 40 04             	mov    0x4(%eax),%eax
80105d7b:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d7f:	c7 44 24 04 4c 8d 10 	movl   $0x80108d4c,0x4(%esp)
80105d86:	80 
80105d87:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d8a:	89 04 24             	mov    %eax,(%esp)
80105d8d:	e8 8e c5 ff ff       	call   80102320 <dirlink>
80105d92:	85 c0                	test   %eax,%eax
80105d94:	79 0c                	jns    80105da2 <create+0x17f>
      panic("create dots");
80105d96:	c7 04 24 7f 8d 10 80 	movl   $0x80108d7f,(%esp)
80105d9d:	e8 b2 a7 ff ff       	call   80100554 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105da2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105da5:	8b 40 04             	mov    0x4(%eax),%eax
80105da8:	89 44 24 08          	mov    %eax,0x8(%esp)
80105dac:	8d 45 de             	lea    -0x22(%ebp),%eax
80105daf:	89 44 24 04          	mov    %eax,0x4(%esp)
80105db3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105db6:	89 04 24             	mov    %eax,(%esp)
80105db9:	e8 62 c5 ff ff       	call   80102320 <dirlink>
80105dbe:	85 c0                	test   %eax,%eax
80105dc0:	79 0c                	jns    80105dce <create+0x1ab>
    panic("create: dirlink");
80105dc2:	c7 04 24 8b 8d 10 80 	movl   $0x80108d8b,(%esp)
80105dc9:	e8 86 a7 ff ff       	call   80100554 <panic>

  iunlockput(dp);
80105dce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dd1:	89 04 24             	mov    %eax,(%esp)
80105dd4:	e8 d4 be ff ff       	call   80101cad <iunlockput>

  return ip;
80105dd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105ddc:	c9                   	leave  
80105ddd:	c3                   	ret    

80105dde <sys_open>:

int
sys_open(void)
{
80105dde:	55                   	push   %ebp
80105ddf:	89 e5                	mov    %esp,%ebp
80105de1:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105de4:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105de7:	89 44 24 04          	mov    %eax,0x4(%esp)
80105deb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105df2:	e8 f1 f6 ff ff       	call   801054e8 <argstr>
80105df7:	85 c0                	test   %eax,%eax
80105df9:	78 17                	js     80105e12 <sys_open+0x34>
80105dfb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105dfe:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e02:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105e09:	e8 43 f6 ff ff       	call   80105451 <argint>
80105e0e:	85 c0                	test   %eax,%eax
80105e10:	79 0a                	jns    80105e1c <sys_open+0x3e>
    return -1;
80105e12:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e17:	e9 5b 01 00 00       	jmp    80105f77 <sys_open+0x199>

  begin_op();
80105e1c:	e8 86 d7 ff ff       	call   801035a7 <begin_op>

  if(omode & O_CREATE){
80105e21:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105e24:	25 00 02 00 00       	and    $0x200,%eax
80105e29:	85 c0                	test   %eax,%eax
80105e2b:	74 3b                	je     80105e68 <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
80105e2d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105e30:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105e37:	00 
80105e38:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105e3f:	00 
80105e40:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80105e47:	00 
80105e48:	89 04 24             	mov    %eax,(%esp)
80105e4b:	e8 d3 fd ff ff       	call   80105c23 <create>
80105e50:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105e53:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e57:	75 6a                	jne    80105ec3 <sys_open+0xe5>
      end_op();
80105e59:	e8 cb d7 ff ff       	call   80103629 <end_op>
      return -1;
80105e5e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e63:	e9 0f 01 00 00       	jmp    80105f77 <sys_open+0x199>
    }
  } else {
    if((ip = namei(path)) == 0){
80105e68:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105e6b:	89 04 24             	mov    %eax,(%esp)
80105e6e:	e8 60 c7 ff ff       	call   801025d3 <namei>
80105e73:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e76:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e7a:	75 0f                	jne    80105e8b <sys_open+0xad>
      end_op();
80105e7c:	e8 a8 d7 ff ff       	call   80103629 <end_op>
      return -1;
80105e81:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e86:	e9 ec 00 00 00       	jmp    80105f77 <sys_open+0x199>
    }
    ilock(ip);
80105e8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e8e:	89 04 24             	mov    %eax,(%esp)
80105e91:	e8 18 bc ff ff       	call   80101aae <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80105e96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e99:	8b 40 50             	mov    0x50(%eax),%eax
80105e9c:	66 83 f8 01          	cmp    $0x1,%ax
80105ea0:	75 21                	jne    80105ec3 <sys_open+0xe5>
80105ea2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ea5:	85 c0                	test   %eax,%eax
80105ea7:	74 1a                	je     80105ec3 <sys_open+0xe5>
      iunlockput(ip);
80105ea9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eac:	89 04 24             	mov    %eax,(%esp)
80105eaf:	e8 f9 bd ff ff       	call   80101cad <iunlockput>
      end_op();
80105eb4:	e8 70 d7 ff ff       	call   80103629 <end_op>
      return -1;
80105eb9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ebe:	e9 b4 00 00 00       	jmp    80105f77 <sys_open+0x199>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105ec3:	e8 24 b2 ff ff       	call   801010ec <filealloc>
80105ec8:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ecb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ecf:	74 14                	je     80105ee5 <sys_open+0x107>
80105ed1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ed4:	89 04 24             	mov    %eax,(%esp)
80105ed7:	e8 40 f7 ff ff       	call   8010561c <fdalloc>
80105edc:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105edf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105ee3:	79 28                	jns    80105f0d <sys_open+0x12f>
    if(f)
80105ee5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ee9:	74 0b                	je     80105ef6 <sys_open+0x118>
      fileclose(f);
80105eeb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eee:	89 04 24             	mov    %eax,(%esp)
80105ef1:	e8 9e b2 ff ff       	call   80101194 <fileclose>
    iunlockput(ip);
80105ef6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ef9:	89 04 24             	mov    %eax,(%esp)
80105efc:	e8 ac bd ff ff       	call   80101cad <iunlockput>
    end_op();
80105f01:	e8 23 d7 ff ff       	call   80103629 <end_op>
    return -1;
80105f06:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f0b:	eb 6a                	jmp    80105f77 <sys_open+0x199>
  }
  iunlock(ip);
80105f0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f10:	89 04 24             	mov    %eax,(%esp)
80105f13:	e8 a0 bc ff ff       	call   80101bb8 <iunlock>
  end_op();
80105f18:	e8 0c d7 ff ff       	call   80103629 <end_op>

  f->type = FD_INODE;
80105f1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f20:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105f26:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f29:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f2c:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105f2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f32:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105f39:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f3c:	83 e0 01             	and    $0x1,%eax
80105f3f:	85 c0                	test   %eax,%eax
80105f41:	0f 94 c0             	sete   %al
80105f44:	88 c2                	mov    %al,%dl
80105f46:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f49:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105f4c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f4f:	83 e0 01             	and    $0x1,%eax
80105f52:	85 c0                	test   %eax,%eax
80105f54:	75 0a                	jne    80105f60 <sys_open+0x182>
80105f56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f59:	83 e0 02             	and    $0x2,%eax
80105f5c:	85 c0                	test   %eax,%eax
80105f5e:	74 07                	je     80105f67 <sys_open+0x189>
80105f60:	b8 01 00 00 00       	mov    $0x1,%eax
80105f65:	eb 05                	jmp    80105f6c <sys_open+0x18e>
80105f67:	b8 00 00 00 00       	mov    $0x0,%eax
80105f6c:	88 c2                	mov    %al,%dl
80105f6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f71:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105f74:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105f77:	c9                   	leave  
80105f78:	c3                   	ret    

80105f79 <sys_mkdir>:

int
sys_mkdir(void)
{
80105f79:	55                   	push   %ebp
80105f7a:	89 e5                	mov    %esp,%ebp
80105f7c:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105f7f:	e8 23 d6 ff ff       	call   801035a7 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105f84:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105f87:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f8b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105f92:	e8 51 f5 ff ff       	call   801054e8 <argstr>
80105f97:	85 c0                	test   %eax,%eax
80105f99:	78 2c                	js     80105fc7 <sys_mkdir+0x4e>
80105f9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f9e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105fa5:	00 
80105fa6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105fad:	00 
80105fae:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80105fb5:	00 
80105fb6:	89 04 24             	mov    %eax,(%esp)
80105fb9:	e8 65 fc ff ff       	call   80105c23 <create>
80105fbe:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105fc1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fc5:	75 0c                	jne    80105fd3 <sys_mkdir+0x5a>
    end_op();
80105fc7:	e8 5d d6 ff ff       	call   80103629 <end_op>
    return -1;
80105fcc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fd1:	eb 15                	jmp    80105fe8 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
80105fd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fd6:	89 04 24             	mov    %eax,(%esp)
80105fd9:	e8 cf bc ff ff       	call   80101cad <iunlockput>
  end_op();
80105fde:	e8 46 d6 ff ff       	call   80103629 <end_op>
  return 0;
80105fe3:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105fe8:	c9                   	leave  
80105fe9:	c3                   	ret    

80105fea <sys_mknod>:

int
sys_mknod(void)
{
80105fea:	55                   	push   %ebp
80105feb:	89 e5                	mov    %esp,%ebp
80105fed:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105ff0:	e8 b2 d5 ff ff       	call   801035a7 <begin_op>
  if((argstr(0, &path)) < 0 ||
80105ff5:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ff8:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ffc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106003:	e8 e0 f4 ff ff       	call   801054e8 <argstr>
80106008:	85 c0                	test   %eax,%eax
8010600a:	78 5e                	js     8010606a <sys_mknod+0x80>
     argint(1, &major) < 0 ||
8010600c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010600f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106013:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010601a:	e8 32 f4 ff ff       	call   80105451 <argint>
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
8010601f:	85 c0                	test   %eax,%eax
80106021:	78 47                	js     8010606a <sys_mknod+0x80>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106023:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106026:	89 44 24 04          	mov    %eax,0x4(%esp)
8010602a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106031:	e8 1b f4 ff ff       	call   80105451 <argint>
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80106036:	85 c0                	test   %eax,%eax
80106038:	78 30                	js     8010606a <sys_mknod+0x80>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
8010603a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010603d:	0f bf c8             	movswl %ax,%ecx
80106040:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106043:	0f bf d0             	movswl %ax,%edx
80106046:	8b 45 f0             	mov    -0x10(%ebp),%eax
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106049:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010604d:	89 54 24 08          	mov    %edx,0x8(%esp)
80106051:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106058:	00 
80106059:	89 04 24             	mov    %eax,(%esp)
8010605c:	e8 c2 fb ff ff       	call   80105c23 <create>
80106061:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106064:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106068:	75 0c                	jne    80106076 <sys_mknod+0x8c>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
8010606a:	e8 ba d5 ff ff       	call   80103629 <end_op>
    return -1;
8010606f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106074:	eb 15                	jmp    8010608b <sys_mknod+0xa1>
  }
  iunlockput(ip);
80106076:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106079:	89 04 24             	mov    %eax,(%esp)
8010607c:	e8 2c bc ff ff       	call   80101cad <iunlockput>
  end_op();
80106081:	e8 a3 d5 ff ff       	call   80103629 <end_op>
  return 0;
80106086:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010608b:	c9                   	leave  
8010608c:	c3                   	ret    

8010608d <sys_chdir>:

int
sys_chdir(void)
{
8010608d:	55                   	push   %ebp
8010608e:	89 e5                	mov    %esp,%ebp
80106090:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80106093:	e8 07 e2 ff ff       	call   8010429f <myproc>
80106098:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
8010609b:	e8 07 d5 ff ff       	call   801035a7 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801060a0:	8d 45 ec             	lea    -0x14(%ebp),%eax
801060a3:	89 44 24 04          	mov    %eax,0x4(%esp)
801060a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801060ae:	e8 35 f4 ff ff       	call   801054e8 <argstr>
801060b3:	85 c0                	test   %eax,%eax
801060b5:	78 14                	js     801060cb <sys_chdir+0x3e>
801060b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801060ba:	89 04 24             	mov    %eax,(%esp)
801060bd:	e8 11 c5 ff ff       	call   801025d3 <namei>
801060c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
801060c5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801060c9:	75 0c                	jne    801060d7 <sys_chdir+0x4a>
    end_op();
801060cb:	e8 59 d5 ff ff       	call   80103629 <end_op>
    return -1;
801060d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060d5:	eb 5a                	jmp    80106131 <sys_chdir+0xa4>
  }
  ilock(ip);
801060d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060da:	89 04 24             	mov    %eax,(%esp)
801060dd:	e8 cc b9 ff ff       	call   80101aae <ilock>
  if(ip->type != T_DIR){
801060e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060e5:	8b 40 50             	mov    0x50(%eax),%eax
801060e8:	66 83 f8 01          	cmp    $0x1,%ax
801060ec:	74 17                	je     80106105 <sys_chdir+0x78>
    iunlockput(ip);
801060ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060f1:	89 04 24             	mov    %eax,(%esp)
801060f4:	e8 b4 bb ff ff       	call   80101cad <iunlockput>
    end_op();
801060f9:	e8 2b d5 ff ff       	call   80103629 <end_op>
    return -1;
801060fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106103:	eb 2c                	jmp    80106131 <sys_chdir+0xa4>
  }
  iunlock(ip);
80106105:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106108:	89 04 24             	mov    %eax,(%esp)
8010610b:	e8 a8 ba ff ff       	call   80101bb8 <iunlock>
  iput(curproc->cwd);
80106110:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106113:	8b 40 68             	mov    0x68(%eax),%eax
80106116:	89 04 24             	mov    %eax,(%esp)
80106119:	e8 de ba ff ff       	call   80101bfc <iput>
  end_op();
8010611e:	e8 06 d5 ff ff       	call   80103629 <end_op>
  curproc->cwd = ip;
80106123:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106126:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106129:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
8010612c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106131:	c9                   	leave  
80106132:	c3                   	ret    

80106133 <sys_exec>:

int
sys_exec(void)
{
80106133:	55                   	push   %ebp
80106134:	89 e5                	mov    %esp,%ebp
80106136:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
8010613c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010613f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106143:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010614a:	e8 99 f3 ff ff       	call   801054e8 <argstr>
8010614f:	85 c0                	test   %eax,%eax
80106151:	78 1a                	js     8010616d <sys_exec+0x3a>
80106153:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106159:	89 44 24 04          	mov    %eax,0x4(%esp)
8010615d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106164:	e8 e8 f2 ff ff       	call   80105451 <argint>
80106169:	85 c0                	test   %eax,%eax
8010616b:	79 0a                	jns    80106177 <sys_exec+0x44>
    return -1;
8010616d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106172:	e9 c7 00 00 00       	jmp    8010623e <sys_exec+0x10b>
  }
  memset(argv, 0, sizeof(argv));
80106177:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
8010617e:	00 
8010617f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106186:	00 
80106187:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010618d:	89 04 24             	mov    %eax,(%esp)
80106190:	e8 89 ef ff ff       	call   8010511e <memset>
  for(i=0;; i++){
80106195:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
8010619c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010619f:	83 f8 1f             	cmp    $0x1f,%eax
801061a2:	76 0a                	jbe    801061ae <sys_exec+0x7b>
      return -1;
801061a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061a9:	e9 90 00 00 00       	jmp    8010623e <sys_exec+0x10b>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801061ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061b1:	c1 e0 02             	shl    $0x2,%eax
801061b4:	89 c2                	mov    %eax,%edx
801061b6:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801061bc:	01 c2                	add    %eax,%edx
801061be:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801061c4:	89 44 24 04          	mov    %eax,0x4(%esp)
801061c8:	89 14 24             	mov    %edx,(%esp)
801061cb:	e8 e0 f1 ff ff       	call   801053b0 <fetchint>
801061d0:	85 c0                	test   %eax,%eax
801061d2:	79 07                	jns    801061db <sys_exec+0xa8>
      return -1;
801061d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061d9:	eb 63                	jmp    8010623e <sys_exec+0x10b>
    if(uarg == 0){
801061db:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801061e1:	85 c0                	test   %eax,%eax
801061e3:	75 26                	jne    8010620b <sys_exec+0xd8>
      argv[i] = 0;
801061e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061e8:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801061ef:	00 00 00 00 
      break;
801061f3:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801061f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061f7:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801061fd:	89 54 24 04          	mov    %edx,0x4(%esp)
80106201:	89 04 24             	mov    %eax,(%esp)
80106204:	e8 87 aa ff ff       	call   80100c90 <exec>
80106209:	eb 33                	jmp    8010623e <sys_exec+0x10b>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
8010620b:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106211:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106214:	c1 e2 02             	shl    $0x2,%edx
80106217:	01 c2                	add    %eax,%edx
80106219:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010621f:	89 54 24 04          	mov    %edx,0x4(%esp)
80106223:	89 04 24             	mov    %eax,(%esp)
80106226:	e8 c4 f1 ff ff       	call   801053ef <fetchstr>
8010622b:	85 c0                	test   %eax,%eax
8010622d:	79 07                	jns    80106236 <sys_exec+0x103>
      return -1;
8010622f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106234:	eb 08                	jmp    8010623e <sys_exec+0x10b>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106236:	ff 45 f4             	incl   -0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106239:	e9 5e ff ff ff       	jmp    8010619c <sys_exec+0x69>
  return exec(path, argv);
}
8010623e:	c9                   	leave  
8010623f:	c3                   	ret    

80106240 <sys_pipe>:

int
sys_pipe(void)
{
80106240:	55                   	push   %ebp
80106241:	89 e5                	mov    %esp,%ebp
80106243:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106246:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
8010624d:	00 
8010624e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106251:	89 44 24 04          	mov    %eax,0x4(%esp)
80106255:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010625c:	e8 1d f2 ff ff       	call   8010547e <argptr>
80106261:	85 c0                	test   %eax,%eax
80106263:	79 0a                	jns    8010626f <sys_pipe+0x2f>
    return -1;
80106265:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010626a:	e9 9a 00 00 00       	jmp    80106309 <sys_pipe+0xc9>
  if(pipealloc(&rf, &wf) < 0)
8010626f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106272:	89 44 24 04          	mov    %eax,0x4(%esp)
80106276:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106279:	89 04 24             	mov    %eax,(%esp)
8010627c:	e8 73 db ff ff       	call   80103df4 <pipealloc>
80106281:	85 c0                	test   %eax,%eax
80106283:	79 07                	jns    8010628c <sys_pipe+0x4c>
    return -1;
80106285:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010628a:	eb 7d                	jmp    80106309 <sys_pipe+0xc9>
  fd0 = -1;
8010628c:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106293:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106296:	89 04 24             	mov    %eax,(%esp)
80106299:	e8 7e f3 ff ff       	call   8010561c <fdalloc>
8010629e:	89 45 f4             	mov    %eax,-0xc(%ebp)
801062a1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062a5:	78 14                	js     801062bb <sys_pipe+0x7b>
801062a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062aa:	89 04 24             	mov    %eax,(%esp)
801062ad:	e8 6a f3 ff ff       	call   8010561c <fdalloc>
801062b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
801062b5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801062b9:	79 36                	jns    801062f1 <sys_pipe+0xb1>
    if(fd0 >= 0)
801062bb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062bf:	78 13                	js     801062d4 <sys_pipe+0x94>
      myproc()->ofile[fd0] = 0;
801062c1:	e8 d9 df ff ff       	call   8010429f <myproc>
801062c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801062c9:	83 c2 08             	add    $0x8,%edx
801062cc:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801062d3:	00 
    fileclose(rf);
801062d4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801062d7:	89 04 24             	mov    %eax,(%esp)
801062da:	e8 b5 ae ff ff       	call   80101194 <fileclose>
    fileclose(wf);
801062df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062e2:	89 04 24             	mov    %eax,(%esp)
801062e5:	e8 aa ae ff ff       	call   80101194 <fileclose>
    return -1;
801062ea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062ef:	eb 18                	jmp    80106309 <sys_pipe+0xc9>
  }
  fd[0] = fd0;
801062f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801062f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801062f7:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801062f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801062fc:	8d 50 04             	lea    0x4(%eax),%edx
801062ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106302:	89 02                	mov    %eax,(%edx)
  return 0;
80106304:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106309:	c9                   	leave  
8010630a:	c3                   	ret    
	...

8010630c <sys_fork>:
#include "proc.h"
#include "container.h"

int
sys_fork(void)
{
8010630c:	55                   	push   %ebp
8010630d:	89 e5                	mov    %esp,%ebp
8010630f:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106312:	e8 91 e2 ff ff       	call   801045a8 <fork>
}
80106317:	c9                   	leave  
80106318:	c3                   	ret    

80106319 <sys_exit>:

int
sys_exit(void)
{
80106319:	55                   	push   %ebp
8010631a:	89 e5                	mov    %esp,%ebp
8010631c:	83 ec 08             	sub    $0x8,%esp
  exit();
8010631f:	e8 ea e3 ff ff       	call   8010470e <exit>
  return 0;  // not reached
80106324:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106329:	c9                   	leave  
8010632a:	c3                   	ret    

8010632b <sys_wait>:

int
sys_wait(void)
{
8010632b:	55                   	push   %ebp
8010632c:	89 e5                	mov    %esp,%ebp
8010632e:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106331:	e8 e1 e4 ff ff       	call   80104817 <wait>
}
80106336:	c9                   	leave  
80106337:	c3                   	ret    

80106338 <sys_kill>:

int
sys_kill(void)
{
80106338:	55                   	push   %ebp
80106339:	89 e5                	mov    %esp,%ebp
8010633b:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010633e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106341:	89 44 24 04          	mov    %eax,0x4(%esp)
80106345:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010634c:	e8 00 f1 ff ff       	call   80105451 <argint>
80106351:	85 c0                	test   %eax,%eax
80106353:	79 07                	jns    8010635c <sys_kill+0x24>
    return -1;
80106355:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010635a:	eb 0b                	jmp    80106367 <sys_kill+0x2f>
  return kill(pid);
8010635c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010635f:	89 04 24             	mov    %eax,(%esp)
80106362:	e8 85 e8 ff ff       	call   80104bec <kill>
}
80106367:	c9                   	leave  
80106368:	c3                   	ret    

80106369 <sys_getpid>:

int
sys_getpid(void)
{
80106369:	55                   	push   %ebp
8010636a:	89 e5                	mov    %esp,%ebp
8010636c:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
8010636f:	e8 2b df ff ff       	call   8010429f <myproc>
80106374:	8b 40 10             	mov    0x10(%eax),%eax
}
80106377:	c9                   	leave  
80106378:	c3                   	ret    

80106379 <sys_sbrk>:

int
sys_sbrk(void)
{
80106379:	55                   	push   %ebp
8010637a:	89 e5                	mov    %esp,%ebp
8010637c:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010637f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106382:	89 44 24 04          	mov    %eax,0x4(%esp)
80106386:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010638d:	e8 bf f0 ff ff       	call   80105451 <argint>
80106392:	85 c0                	test   %eax,%eax
80106394:	79 07                	jns    8010639d <sys_sbrk+0x24>
    return -1;
80106396:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010639b:	eb 23                	jmp    801063c0 <sys_sbrk+0x47>
  addr = myproc()->sz;
8010639d:	e8 fd de ff ff       	call   8010429f <myproc>
801063a2:	8b 00                	mov    (%eax),%eax
801063a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801063a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063aa:	89 04 24             	mov    %eax,(%esp)
801063ad:	e8 58 e1 ff ff       	call   8010450a <growproc>
801063b2:	85 c0                	test   %eax,%eax
801063b4:	79 07                	jns    801063bd <sys_sbrk+0x44>
    return -1;
801063b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063bb:	eb 03                	jmp    801063c0 <sys_sbrk+0x47>
  return addr;
801063bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801063c0:	c9                   	leave  
801063c1:	c3                   	ret    

801063c2 <sys_sleep>:

int
sys_sleep(void)
{
801063c2:	55                   	push   %ebp
801063c3:	89 e5                	mov    %esp,%ebp
801063c5:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
801063c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063cb:	89 44 24 04          	mov    %eax,0x4(%esp)
801063cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801063d6:	e8 76 f0 ff ff       	call   80105451 <argint>
801063db:	85 c0                	test   %eax,%eax
801063dd:	79 07                	jns    801063e6 <sys_sleep+0x24>
    return -1;
801063df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063e4:	eb 6b                	jmp    80106451 <sys_sleep+0x8f>
  acquire(&tickslock);
801063e6:	c7 04 24 80 60 11 80 	movl   $0x80116080,(%esp)
801063ed:	e8 c9 ea ff ff       	call   80104ebb <acquire>
  ticks0 = ticks;
801063f2:	a1 c0 68 11 80       	mov    0x801168c0,%eax
801063f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801063fa:	eb 33                	jmp    8010642f <sys_sleep+0x6d>
    if(myproc()->killed){
801063fc:	e8 9e de ff ff       	call   8010429f <myproc>
80106401:	8b 40 24             	mov    0x24(%eax),%eax
80106404:	85 c0                	test   %eax,%eax
80106406:	74 13                	je     8010641b <sys_sleep+0x59>
      release(&tickslock);
80106408:	c7 04 24 80 60 11 80 	movl   $0x80116080,(%esp)
8010640f:	e8 11 eb ff ff       	call   80104f25 <release>
      return -1;
80106414:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106419:	eb 36                	jmp    80106451 <sys_sleep+0x8f>
    }
    sleep(&ticks, &tickslock);
8010641b:	c7 44 24 04 80 60 11 	movl   $0x80116080,0x4(%esp)
80106422:	80 
80106423:	c7 04 24 c0 68 11 80 	movl   $0x801168c0,(%esp)
8010642a:	e8 be e6 ff ff       	call   80104aed <sleep>

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
8010642f:	a1 c0 68 11 80       	mov    0x801168c0,%eax
80106434:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106437:	89 c2                	mov    %eax,%edx
80106439:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010643c:	39 c2                	cmp    %eax,%edx
8010643e:	72 bc                	jb     801063fc <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106440:	c7 04 24 80 60 11 80 	movl   $0x80116080,(%esp)
80106447:	e8 d9 ea ff ff       	call   80104f25 <release>
  return 0;
8010644c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106451:	c9                   	leave  
80106452:	c3                   	ret    

80106453 <sys_get_name>:

void sys_get_name(void){
80106453:	55                   	push   %ebp
80106454:	89 e5                	mov    %esp,%ebp
80106456:	83 ec 28             	sub    $0x28,%esp

  char* name;
  fetchstr(0, &name);
80106459:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010645c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106460:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106467:	e8 83 ef ff ff       	call   801053ef <fetchstr>

  int vc_num;
  fetchint(1, &vc_num);
8010646c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010646f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106473:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010647a:	e8 31 ef ff ff       	call   801053b0 <fetchint>

  get_name(name, vc_num);
8010647f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106482:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106485:	89 54 24 04          	mov    %edx,0x4(%esp)
80106489:	89 04 24             	mov    %eax,(%esp)
8010648c:	e8 21 21 00 00       	call   801085b2 <get_name>
  return;
80106491:	90                   	nop
}
80106492:	c9                   	leave  
80106493:	c3                   	ret    

80106494 <sys_get_max_proc>:

int sys_get_max_proc(void){
80106494:	55                   	push   %ebp
80106495:	89 e5                	mov    %esp,%ebp
80106497:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  fetchint(0, &vc_num);
8010649a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010649d:	89 44 24 04          	mov    %eax,0x4(%esp)
801064a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801064a8:	e8 03 ef ff ff       	call   801053b0 <fetchint>


  return get_max_proc(vc_num);  
801064ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064b0:	89 04 24             	mov    %eax,(%esp)
801064b3:	e8 48 21 00 00       	call   80108600 <get_max_proc>
}
801064b8:	c9                   	leave  
801064b9:	c3                   	ret    

801064ba <sys_get_max_mem>:

int sys_get_max_mem(void){
801064ba:	55                   	push   %ebp
801064bb:	89 e5                	mov    %esp,%ebp
801064bd:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  fetchint(0, &vc_num);
801064c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
801064c3:	89 44 24 04          	mov    %eax,0x4(%esp)
801064c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801064ce:	e8 dd ee ff ff       	call   801053b0 <fetchint>


  return get_max_mem(vc_num);
801064d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064d6:	89 04 24             	mov    %eax,(%esp)
801064d9:	e8 61 21 00 00       	call   8010863f <get_max_mem>
}
801064de:	c9                   	leave  
801064df:	c3                   	ret    

801064e0 <sys_get_max_disk>:

int sys_get_max_disk(void){
801064e0:	55                   	push   %ebp
801064e1:	89 e5                	mov    %esp,%ebp
801064e3:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  fetchint(0, &vc_num);
801064e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
801064e9:	89 44 24 04          	mov    %eax,0x4(%esp)
801064ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801064f4:	e8 b7 ee ff ff       	call   801053b0 <fetchint>


  return get_max_disk(vc_num);
801064f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064fc:	89 04 24             	mov    %eax,(%esp)
801064ff:	e8 7a 21 00 00       	call   8010867e <get_max_disk>

}
80106504:	c9                   	leave  
80106505:	c3                   	ret    

80106506 <sys_get_curr_proc>:

int sys_get_curr_proc(void){
80106506:	55                   	push   %ebp
80106507:	89 e5                	mov    %esp,%ebp
80106509:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  fetchint(0, &vc_num);
8010650c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010650f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106513:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010651a:	e8 91 ee ff ff       	call   801053b0 <fetchint>


  return get_curr_proc(vc_num);
8010651f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106522:	89 04 24             	mov    %eax,(%esp)
80106525:	e8 93 21 00 00       	call   801086bd <get_curr_proc>
}
8010652a:	c9                   	leave  
8010652b:	c3                   	ret    

8010652c <sys_get_curr_mem>:

int sys_get_curr_mem(void){
8010652c:	55                   	push   %ebp
8010652d:	89 e5                	mov    %esp,%ebp
8010652f:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  fetchint(0, &vc_num);
80106532:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106535:	89 44 24 04          	mov    %eax,0x4(%esp)
80106539:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106540:	e8 6b ee ff ff       	call   801053b0 <fetchint>


  return get_curr_mem(vc_num);
80106545:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106548:	89 04 24             	mov    %eax,(%esp)
8010654b:	e8 ac 21 00 00       	call   801086fc <get_curr_mem>
}
80106550:	c9                   	leave  
80106551:	c3                   	ret    

80106552 <sys_get_curr_disk>:

int sys_get_curr_disk(void){
80106552:	55                   	push   %ebp
80106553:	89 e5                	mov    %esp,%ebp
80106555:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  fetchint(0, &vc_num);
80106558:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010655b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010655f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106566:	e8 45 ee ff ff       	call   801053b0 <fetchint>


  return get_curr_disk(vc_num);
8010656b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010656e:	89 04 24             	mov    %eax,(%esp)
80106571:	e8 c5 21 00 00       	call   8010873b <get_curr_disk>
}
80106576:	c9                   	leave  
80106577:	c3                   	ret    

80106578 <sys_set_name>:

void sys_set_name(void){
80106578:	55                   	push   %ebp
80106579:	89 e5                	mov    %esp,%ebp
8010657b:	83 ec 28             	sub    $0x28,%esp
  char* name;
  fetchstr(0, &name);
8010657e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106581:	89 44 24 04          	mov    %eax,0x4(%esp)
80106585:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010658c:	e8 5e ee ff ff       	call   801053ef <fetchstr>

  int vc_num;
  fetchint(1, &vc_num);
80106591:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106594:	89 44 24 04          	mov    %eax,0x4(%esp)
80106598:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010659f:	e8 0c ee ff ff       	call   801053b0 <fetchint>

  set_name(name, vc_num);
801065a4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801065a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065aa:	89 54 24 04          	mov    %edx,0x4(%esp)
801065ae:	89 04 24             	mov    %eax,(%esp)
801065b1:	e8 c4 21 00 00       	call   8010877a <set_name>
}
801065b6:	c9                   	leave  
801065b7:	c3                   	ret    

801065b8 <sys_set_max_mem>:

void sys_set_max_mem(void){
801065b8:	55                   	push   %ebp
801065b9:	89 e5                	mov    %esp,%ebp
801065bb:	83 ec 28             	sub    $0x28,%esp
  int mem;
  fetchint(0, &mem);
801065be:	8d 45 f4             	lea    -0xc(%ebp),%eax
801065c1:	89 44 24 04          	mov    %eax,0x4(%esp)
801065c5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801065cc:	e8 df ed ff ff       	call   801053b0 <fetchint>

  int vc_num;
  fetchint(1, &vc_num);
801065d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801065d4:	89 44 24 04          	mov    %eax,0x4(%esp)
801065d8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801065df:	e8 cc ed ff ff       	call   801053b0 <fetchint>

  set_max_mem(mem, vc_num);
801065e4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801065e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065ea:	89 54 24 04          	mov    %edx,0x4(%esp)
801065ee:	89 04 24             	mov    %eax,(%esp)
801065f1:	e8 b7 21 00 00       	call   801087ad <set_max_mem>
}
801065f6:	c9                   	leave  
801065f7:	c3                   	ret    

801065f8 <sys_set_max_disk>:

void sys_set_max_disk(void){
801065f8:	55                   	push   %ebp
801065f9:	89 e5                	mov    %esp,%ebp
801065fb:	83 ec 28             	sub    $0x28,%esp
  int disk;
  fetchint(0, &disk);
801065fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106601:	89 44 24 04          	mov    %eax,0x4(%esp)
80106605:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010660c:	e8 9f ed ff ff       	call   801053b0 <fetchint>

  int vc_num;
  fetchint(1, &vc_num);
80106611:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106614:	89 44 24 04          	mov    %eax,0x4(%esp)
80106618:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010661f:	e8 8c ed ff ff       	call   801053b0 <fetchint>

  set_max_disk(disk, vc_num);
80106624:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106627:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010662a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010662e:	89 04 24             	mov    %eax,(%esp)
80106631:	e8 9b 21 00 00       	call   801087d1 <set_max_disk>
}
80106636:	c9                   	leave  
80106637:	c3                   	ret    

80106638 <sys_set_max_proc>:

void sys_set_max_proc(void){
80106638:	55                   	push   %ebp
80106639:	89 e5                	mov    %esp,%ebp
8010663b:	83 ec 28             	sub    $0x28,%esp
  int proc;
  fetchint(0, &proc);
8010663e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106641:	89 44 24 04          	mov    %eax,0x4(%esp)
80106645:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010664c:	e8 5f ed ff ff       	call   801053b0 <fetchint>

  int vc_num;
  fetchint(1, &vc_num);
80106651:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106654:	89 44 24 04          	mov    %eax,0x4(%esp)
80106658:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010665f:	e8 4c ed ff ff       	call   801053b0 <fetchint>

  set_max_proc(proc, vc_num);
80106664:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106667:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010666a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010666e:	89 04 24             	mov    %eax,(%esp)
80106671:	e8 80 21 00 00       	call   801087f6 <set_max_proc>
}
80106676:	c9                   	leave  
80106677:	c3                   	ret    

80106678 <sys_set_curr_mem>:

void sys_set_curr_mem(void){
80106678:	55                   	push   %ebp
80106679:	89 e5                	mov    %esp,%ebp
8010667b:	83 ec 28             	sub    $0x28,%esp
  int mem;
  fetchint(0, &mem);
8010667e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106681:	89 44 24 04          	mov    %eax,0x4(%esp)
80106685:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010668c:	e8 1f ed ff ff       	call   801053b0 <fetchint>

  int vc_num;
  fetchint(1, &vc_num);
80106691:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106694:	89 44 24 04          	mov    %eax,0x4(%esp)
80106698:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010669f:	e8 0c ed ff ff       	call   801053b0 <fetchint>

  set_curr_mem(mem, vc_num);
801066a4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801066a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066aa:	89 54 24 04          	mov    %edx,0x4(%esp)
801066ae:	89 04 24             	mov    %eax,(%esp)
801066b1:	e8 65 21 00 00       	call   8010881b <set_curr_mem>
}
801066b6:	c9                   	leave  
801066b7:	c3                   	ret    

801066b8 <sys_set_curr_disk>:

void sys_set_curr_disk(void){
801066b8:	55                   	push   %ebp
801066b9:	89 e5                	mov    %esp,%ebp
801066bb:	83 ec 28             	sub    $0x28,%esp
  int disk;
  fetchint(0, &disk);
801066be:	8d 45 f4             	lea    -0xc(%ebp),%eax
801066c1:	89 44 24 04          	mov    %eax,0x4(%esp)
801066c5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801066cc:	e8 df ec ff ff       	call   801053b0 <fetchint>

  int vc_num;
  fetchint(1, &vc_num);
801066d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801066d4:	89 44 24 04          	mov    %eax,0x4(%esp)
801066d8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801066df:	e8 cc ec ff ff       	call   801053b0 <fetchint>

  set_curr_disk(disk, vc_num);
801066e4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801066e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066ea:	89 54 24 04          	mov    %edx,0x4(%esp)
801066ee:	89 04 24             	mov    %eax,(%esp)
801066f1:	e8 4a 21 00 00       	call   80108840 <set_curr_disk>
}
801066f6:	c9                   	leave  
801066f7:	c3                   	ret    

801066f8 <sys_set_curr_proc>:

void sys_set_curr_proc(void){
801066f8:	55                   	push   %ebp
801066f9:	89 e5                	mov    %esp,%ebp
801066fb:	83 ec 28             	sub    $0x28,%esp
  int proc;
  fetchint(0, &proc);
801066fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106701:	89 44 24 04          	mov    %eax,0x4(%esp)
80106705:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010670c:	e8 9f ec ff ff       	call   801053b0 <fetchint>

  int vc_num;
  fetchint(1, &vc_num);
80106711:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106714:	89 44 24 04          	mov    %eax,0x4(%esp)
80106718:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010671f:	e8 8c ec ff ff       	call   801053b0 <fetchint>

  set_curr_proc(proc, vc_num);
80106724:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106727:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010672a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010672e:	89 04 24             	mov    %eax,(%esp)
80106731:	e8 2f 21 00 00       	call   80108865 <set_curr_proc>
}
80106736:	c9                   	leave  
80106737:	c3                   	ret    

80106738 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106738:	55                   	push   %ebp
80106739:	89 e5                	mov    %esp,%ebp
8010673b:	83 ec 28             	sub    $0x28,%esp
  uint xticks;

  acquire(&tickslock);
8010673e:	c7 04 24 80 60 11 80 	movl   $0x80116080,(%esp)
80106745:	e8 71 e7 ff ff       	call   80104ebb <acquire>
  xticks = ticks;
8010674a:	a1 c0 68 11 80       	mov    0x801168c0,%eax
8010674f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106752:	c7 04 24 80 60 11 80 	movl   $0x80116080,(%esp)
80106759:	e8 c7 e7 ff ff       	call   80104f25 <release>
  return xticks;
8010675e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106761:	c9                   	leave  
80106762:	c3                   	ret    

80106763 <sys_getticks>:

int
sys_getticks(void)
{
80106763:	55                   	push   %ebp
80106764:	89 e5                	mov    %esp,%ebp
80106766:	83 ec 08             	sub    $0x8,%esp
  return myproc()->ticks;
80106769:	e8 31 db ff ff       	call   8010429f <myproc>
8010676e:	8b 40 7c             	mov    0x7c(%eax),%eax
}
80106771:	c9                   	leave  
80106772:	c3                   	ret    
	...

80106774 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106774:	1e                   	push   %ds
  pushl %es
80106775:	06                   	push   %es
  pushl %fs
80106776:	0f a0                	push   %fs
  pushl %gs
80106778:	0f a8                	push   %gs
  pushal
8010677a:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
8010677b:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010677f:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106781:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106783:	54                   	push   %esp
  call trap
80106784:	e8 c0 01 00 00       	call   80106949 <trap>
  addl $4, %esp
80106789:	83 c4 04             	add    $0x4,%esp

8010678c <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
8010678c:	61                   	popa   
  popl %gs
8010678d:	0f a9                	pop    %gs
  popl %fs
8010678f:	0f a1                	pop    %fs
  popl %es
80106791:	07                   	pop    %es
  popl %ds
80106792:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106793:	83 c4 08             	add    $0x8,%esp
  iret
80106796:	cf                   	iret   
	...

80106798 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106798:	55                   	push   %ebp
80106799:	89 e5                	mov    %esp,%ebp
8010679b:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010679e:	8b 45 0c             	mov    0xc(%ebp),%eax
801067a1:	48                   	dec    %eax
801067a2:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801067a6:	8b 45 08             	mov    0x8(%ebp),%eax
801067a9:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801067ad:	8b 45 08             	mov    0x8(%ebp),%eax
801067b0:	c1 e8 10             	shr    $0x10,%eax
801067b3:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
801067b7:	8d 45 fa             	lea    -0x6(%ebp),%eax
801067ba:	0f 01 18             	lidtl  (%eax)
}
801067bd:	c9                   	leave  
801067be:	c3                   	ret    

801067bf <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
801067bf:	55                   	push   %ebp
801067c0:	89 e5                	mov    %esp,%ebp
801067c2:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801067c5:	0f 20 d0             	mov    %cr2,%eax
801067c8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801067cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801067ce:	c9                   	leave  
801067cf:	c3                   	ret    

801067d0 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801067d0:	55                   	push   %ebp
801067d1:	89 e5                	mov    %esp,%ebp
801067d3:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
801067d6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801067dd:	e9 b8 00 00 00       	jmp    8010689a <tvinit+0xca>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801067e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067e5:	8b 04 85 b4 b0 10 80 	mov    -0x7fef4f4c(,%eax,4),%eax
801067ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
801067ef:	66 89 04 d5 c0 60 11 	mov    %ax,-0x7fee9f40(,%edx,8)
801067f6:	80 
801067f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067fa:	66 c7 04 c5 c2 60 11 	movw   $0x8,-0x7fee9f3e(,%eax,8)
80106801:	80 08 00 
80106804:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106807:	8a 14 c5 c4 60 11 80 	mov    -0x7fee9f3c(,%eax,8),%dl
8010680e:	83 e2 e0             	and    $0xffffffe0,%edx
80106811:	88 14 c5 c4 60 11 80 	mov    %dl,-0x7fee9f3c(,%eax,8)
80106818:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010681b:	8a 14 c5 c4 60 11 80 	mov    -0x7fee9f3c(,%eax,8),%dl
80106822:	83 e2 1f             	and    $0x1f,%edx
80106825:	88 14 c5 c4 60 11 80 	mov    %dl,-0x7fee9f3c(,%eax,8)
8010682c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010682f:	8a 14 c5 c5 60 11 80 	mov    -0x7fee9f3b(,%eax,8),%dl
80106836:	83 e2 f0             	and    $0xfffffff0,%edx
80106839:	83 ca 0e             	or     $0xe,%edx
8010683c:	88 14 c5 c5 60 11 80 	mov    %dl,-0x7fee9f3b(,%eax,8)
80106843:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106846:	8a 14 c5 c5 60 11 80 	mov    -0x7fee9f3b(,%eax,8),%dl
8010684d:	83 e2 ef             	and    $0xffffffef,%edx
80106850:	88 14 c5 c5 60 11 80 	mov    %dl,-0x7fee9f3b(,%eax,8)
80106857:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010685a:	8a 14 c5 c5 60 11 80 	mov    -0x7fee9f3b(,%eax,8),%dl
80106861:	83 e2 9f             	and    $0xffffff9f,%edx
80106864:	88 14 c5 c5 60 11 80 	mov    %dl,-0x7fee9f3b(,%eax,8)
8010686b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010686e:	8a 14 c5 c5 60 11 80 	mov    -0x7fee9f3b(,%eax,8),%dl
80106875:	83 ca 80             	or     $0xffffff80,%edx
80106878:	88 14 c5 c5 60 11 80 	mov    %dl,-0x7fee9f3b(,%eax,8)
8010687f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106882:	8b 04 85 b4 b0 10 80 	mov    -0x7fef4f4c(,%eax,4),%eax
80106889:	c1 e8 10             	shr    $0x10,%eax
8010688c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010688f:	66 89 04 d5 c6 60 11 	mov    %ax,-0x7fee9f3a(,%edx,8)
80106896:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80106897:	ff 45 f4             	incl   -0xc(%ebp)
8010689a:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801068a1:	0f 8e 3b ff ff ff    	jle    801067e2 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801068a7:	a1 b4 b1 10 80       	mov    0x8010b1b4,%eax
801068ac:	66 a3 c0 62 11 80    	mov    %ax,0x801162c0
801068b2:	66 c7 05 c2 62 11 80 	movw   $0x8,0x801162c2
801068b9:	08 00 
801068bb:	a0 c4 62 11 80       	mov    0x801162c4,%al
801068c0:	83 e0 e0             	and    $0xffffffe0,%eax
801068c3:	a2 c4 62 11 80       	mov    %al,0x801162c4
801068c8:	a0 c4 62 11 80       	mov    0x801162c4,%al
801068cd:	83 e0 1f             	and    $0x1f,%eax
801068d0:	a2 c4 62 11 80       	mov    %al,0x801162c4
801068d5:	a0 c5 62 11 80       	mov    0x801162c5,%al
801068da:	83 c8 0f             	or     $0xf,%eax
801068dd:	a2 c5 62 11 80       	mov    %al,0x801162c5
801068e2:	a0 c5 62 11 80       	mov    0x801162c5,%al
801068e7:	83 e0 ef             	and    $0xffffffef,%eax
801068ea:	a2 c5 62 11 80       	mov    %al,0x801162c5
801068ef:	a0 c5 62 11 80       	mov    0x801162c5,%al
801068f4:	83 c8 60             	or     $0x60,%eax
801068f7:	a2 c5 62 11 80       	mov    %al,0x801162c5
801068fc:	a0 c5 62 11 80       	mov    0x801162c5,%al
80106901:	83 c8 80             	or     $0xffffff80,%eax
80106904:	a2 c5 62 11 80       	mov    %al,0x801162c5
80106909:	a1 b4 b1 10 80       	mov    0x8010b1b4,%eax
8010690e:	c1 e8 10             	shr    $0x10,%eax
80106911:	66 a3 c6 62 11 80    	mov    %ax,0x801162c6

  initlock(&tickslock, "time");
80106917:	c7 44 24 04 9c 8d 10 	movl   $0x80108d9c,0x4(%esp)
8010691e:	80 
8010691f:	c7 04 24 80 60 11 80 	movl   $0x80116080,(%esp)
80106926:	e8 6f e5 ff ff       	call   80104e9a <initlock>
}
8010692b:	c9                   	leave  
8010692c:	c3                   	ret    

8010692d <idtinit>:

void
idtinit(void)
{
8010692d:	55                   	push   %ebp
8010692e:	89 e5                	mov    %esp,%ebp
80106930:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
80106933:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
8010693a:	00 
8010693b:	c7 04 24 c0 60 11 80 	movl   $0x801160c0,(%esp)
80106942:	e8 51 fe ff ff       	call   80106798 <lidt>
}
80106947:	c9                   	leave  
80106948:	c3                   	ret    

80106949 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106949:	55                   	push   %ebp
8010694a:	89 e5                	mov    %esp,%ebp
8010694c:	57                   	push   %edi
8010694d:	56                   	push   %esi
8010694e:	53                   	push   %ebx
8010694f:	83 ec 4c             	sub    $0x4c,%esp
  struct proc *p;
  if(tf->trapno == T_SYSCALL){
80106952:	8b 45 08             	mov    0x8(%ebp),%eax
80106955:	8b 40 30             	mov    0x30(%eax),%eax
80106958:	83 f8 40             	cmp    $0x40,%eax
8010695b:	75 3c                	jne    80106999 <trap+0x50>
    if(myproc()->killed)
8010695d:	e8 3d d9 ff ff       	call   8010429f <myproc>
80106962:	8b 40 24             	mov    0x24(%eax),%eax
80106965:	85 c0                	test   %eax,%eax
80106967:	74 05                	je     8010696e <trap+0x25>
      exit();
80106969:	e8 a0 dd ff ff       	call   8010470e <exit>
    myproc()->tf = tf;
8010696e:	e8 2c d9 ff ff       	call   8010429f <myproc>
80106973:	8b 55 08             	mov    0x8(%ebp),%edx
80106976:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106979:	e8 a1 eb ff ff       	call   8010551f <syscall>
    if(myproc()->killed)
8010697e:	e8 1c d9 ff ff       	call   8010429f <myproc>
80106983:	8b 40 24             	mov    0x24(%eax),%eax
80106986:	85 c0                	test   %eax,%eax
80106988:	74 0a                	je     80106994 <trap+0x4b>
      exit();
8010698a:	e8 7f dd ff ff       	call   8010470e <exit>
    return;
8010698f:	e9 30 02 00 00       	jmp    80106bc4 <trap+0x27b>
80106994:	e9 2b 02 00 00       	jmp    80106bc4 <trap+0x27b>
  }

  switch(tf->trapno){
80106999:	8b 45 08             	mov    0x8(%ebp),%eax
8010699c:	8b 40 30             	mov    0x30(%eax),%eax
8010699f:	83 e8 20             	sub    $0x20,%eax
801069a2:	83 f8 1f             	cmp    $0x1f,%eax
801069a5:	0f 87 cb 00 00 00    	ja     80106a76 <trap+0x12d>
801069ab:	8b 04 85 44 8e 10 80 	mov    -0x7fef71bc(,%eax,4),%eax
801069b2:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
801069b4:	e8 1d d8 ff ff       	call   801041d6 <cpuid>
801069b9:	85 c0                	test   %eax,%eax
801069bb:	75 2f                	jne    801069ec <trap+0xa3>
      acquire(&tickslock);
801069bd:	c7 04 24 80 60 11 80 	movl   $0x80116080,(%esp)
801069c4:	e8 f2 e4 ff ff       	call   80104ebb <acquire>
      ticks++;
801069c9:	a1 c0 68 11 80       	mov    0x801168c0,%eax
801069ce:	40                   	inc    %eax
801069cf:	a3 c0 68 11 80       	mov    %eax,0x801168c0
      wakeup(&ticks);
801069d4:	c7 04 24 c0 68 11 80 	movl   $0x801168c0,(%esp)
801069db:	e8 e1 e1 ff ff       	call   80104bc1 <wakeup>
      release(&tickslock);
801069e0:	c7 04 24 80 60 11 80 	movl   $0x80116080,(%esp)
801069e7:	e8 39 e5 ff ff       	call   80104f25 <release>
    }
    p = myproc();
801069ec:	e8 ae d8 ff ff       	call   8010429f <myproc>
801069f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (p != 0) {
801069f4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801069f8:	74 0f                	je     80106a09 <trap+0xc0>
      p->ticks++;
801069fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801069fd:	8b 40 7c             	mov    0x7c(%eax),%eax
80106a00:	8d 50 01             	lea    0x1(%eax),%edx
80106a03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106a06:	89 50 7c             	mov    %edx,0x7c(%eax)
    }
    lapiceoi();
80106a09:	e8 71 c6 ff ff       	call   8010307f <lapiceoi>
    break;
80106a0e:	e9 35 01 00 00       	jmp    80106b48 <trap+0x1ff>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106a13:	e8 e6 be ff ff       	call   801028fe <ideintr>
    lapiceoi();
80106a18:	e8 62 c6 ff ff       	call   8010307f <lapiceoi>
    break;
80106a1d:	e9 26 01 00 00       	jmp    80106b48 <trap+0x1ff>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106a22:	e8 6f c4 ff ff       	call   80102e96 <kbdintr>
    lapiceoi();
80106a27:	e8 53 c6 ff ff       	call   8010307f <lapiceoi>
    break;
80106a2c:	e9 17 01 00 00       	jmp    80106b48 <trap+0x1ff>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106a31:	e8 6f 03 00 00       	call   80106da5 <uartintr>
    lapiceoi();
80106a36:	e8 44 c6 ff ff       	call   8010307f <lapiceoi>
    break;
80106a3b:	e9 08 01 00 00       	jmp    80106b48 <trap+0x1ff>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106a40:	8b 45 08             	mov    0x8(%ebp),%eax
80106a43:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106a46:	8b 45 08             	mov    0x8(%ebp),%eax
80106a49:	8b 40 3c             	mov    0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106a4c:	0f b7 d8             	movzwl %ax,%ebx
80106a4f:	e8 82 d7 ff ff       	call   801041d6 <cpuid>
80106a54:	89 74 24 0c          	mov    %esi,0xc(%esp)
80106a58:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80106a5c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a60:	c7 04 24 a4 8d 10 80 	movl   $0x80108da4,(%esp)
80106a67:	e8 55 99 ff ff       	call   801003c1 <cprintf>
            cpuid(), tf->cs, tf->eip);
    lapiceoi();
80106a6c:	e8 0e c6 ff ff       	call   8010307f <lapiceoi>
    break;
80106a71:	e9 d2 00 00 00       	jmp    80106b48 <trap+0x1ff>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106a76:	e8 24 d8 ff ff       	call   8010429f <myproc>
80106a7b:	85 c0                	test   %eax,%eax
80106a7d:	74 10                	je     80106a8f <trap+0x146>
80106a7f:	8b 45 08             	mov    0x8(%ebp),%eax
80106a82:	8b 40 3c             	mov    0x3c(%eax),%eax
80106a85:	0f b7 c0             	movzwl %ax,%eax
80106a88:	83 e0 03             	and    $0x3,%eax
80106a8b:	85 c0                	test   %eax,%eax
80106a8d:	75 40                	jne    80106acf <trap+0x186>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106a8f:	e8 2b fd ff ff       	call   801067bf <rcr2>
80106a94:	89 c3                	mov    %eax,%ebx
80106a96:	8b 45 08             	mov    0x8(%ebp),%eax
80106a99:	8b 70 38             	mov    0x38(%eax),%esi
80106a9c:	e8 35 d7 ff ff       	call   801041d6 <cpuid>
80106aa1:	8b 55 08             	mov    0x8(%ebp),%edx
80106aa4:	8b 52 30             	mov    0x30(%edx),%edx
80106aa7:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106aab:	89 74 24 0c          	mov    %esi,0xc(%esp)
80106aaf:	89 44 24 08          	mov    %eax,0x8(%esp)
80106ab3:	89 54 24 04          	mov    %edx,0x4(%esp)
80106ab7:	c7 04 24 c8 8d 10 80 	movl   $0x80108dc8,(%esp)
80106abe:	e8 fe 98 ff ff       	call   801003c1 <cprintf>
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106ac3:	c7 04 24 fa 8d 10 80 	movl   $0x80108dfa,(%esp)
80106aca:	e8 85 9a ff ff       	call   80100554 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106acf:	e8 eb fc ff ff       	call   801067bf <rcr2>
80106ad4:	89 c6                	mov    %eax,%esi
80106ad6:	8b 45 08             	mov    0x8(%ebp),%eax
80106ad9:	8b 40 38             	mov    0x38(%eax),%eax
80106adc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106adf:	e8 f2 d6 ff ff       	call   801041d6 <cpuid>
80106ae4:	89 c3                	mov    %eax,%ebx
80106ae6:	8b 45 08             	mov    0x8(%ebp),%eax
80106ae9:	8b 78 34             	mov    0x34(%eax),%edi
80106aec:	89 7d d0             	mov    %edi,-0x30(%ebp)
80106aef:	8b 45 08             	mov    0x8(%ebp),%eax
80106af2:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106af5:	e8 a5 d7 ff ff       	call   8010429f <myproc>
80106afa:	8d 50 6c             	lea    0x6c(%eax),%edx
80106afd:	89 55 cc             	mov    %edx,-0x34(%ebp)
80106b00:	e8 9a d7 ff ff       	call   8010429f <myproc>
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106b05:	8b 40 10             	mov    0x10(%eax),%eax
80106b08:	89 74 24 1c          	mov    %esi,0x1c(%esp)
80106b0c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
80106b0f:	89 4c 24 18          	mov    %ecx,0x18(%esp)
80106b13:	89 5c 24 14          	mov    %ebx,0x14(%esp)
80106b17:	8b 4d d0             	mov    -0x30(%ebp),%ecx
80106b1a:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80106b1e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
80106b22:	8b 55 cc             	mov    -0x34(%ebp),%edx
80106b25:	89 54 24 08          	mov    %edx,0x8(%esp)
80106b29:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b2d:	c7 04 24 00 8e 10 80 	movl   $0x80108e00,(%esp)
80106b34:	e8 88 98 ff ff       	call   801003c1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106b39:	e8 61 d7 ff ff       	call   8010429f <myproc>
80106b3e:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106b45:	eb 01                	jmp    80106b48 <trap+0x1ff>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106b47:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106b48:	e8 52 d7 ff ff       	call   8010429f <myproc>
80106b4d:	85 c0                	test   %eax,%eax
80106b4f:	74 22                	je     80106b73 <trap+0x22a>
80106b51:	e8 49 d7 ff ff       	call   8010429f <myproc>
80106b56:	8b 40 24             	mov    0x24(%eax),%eax
80106b59:	85 c0                	test   %eax,%eax
80106b5b:	74 16                	je     80106b73 <trap+0x22a>
80106b5d:	8b 45 08             	mov    0x8(%ebp),%eax
80106b60:	8b 40 3c             	mov    0x3c(%eax),%eax
80106b63:	0f b7 c0             	movzwl %ax,%eax
80106b66:	83 e0 03             	and    $0x3,%eax
80106b69:	83 f8 03             	cmp    $0x3,%eax
80106b6c:	75 05                	jne    80106b73 <trap+0x22a>
    exit();
80106b6e:	e8 9b db ff ff       	call   8010470e <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106b73:	e8 27 d7 ff ff       	call   8010429f <myproc>
80106b78:	85 c0                	test   %eax,%eax
80106b7a:	74 1d                	je     80106b99 <trap+0x250>
80106b7c:	e8 1e d7 ff ff       	call   8010429f <myproc>
80106b81:	8b 40 0c             	mov    0xc(%eax),%eax
80106b84:	83 f8 04             	cmp    $0x4,%eax
80106b87:	75 10                	jne    80106b99 <trap+0x250>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106b89:	8b 45 08             	mov    0x8(%ebp),%eax
80106b8c:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106b8f:	83 f8 20             	cmp    $0x20,%eax
80106b92:	75 05                	jne    80106b99 <trap+0x250>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();
80106b94:	e8 e4 de ff ff       	call   80104a7d <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106b99:	e8 01 d7 ff ff       	call   8010429f <myproc>
80106b9e:	85 c0                	test   %eax,%eax
80106ba0:	74 22                	je     80106bc4 <trap+0x27b>
80106ba2:	e8 f8 d6 ff ff       	call   8010429f <myproc>
80106ba7:	8b 40 24             	mov    0x24(%eax),%eax
80106baa:	85 c0                	test   %eax,%eax
80106bac:	74 16                	je     80106bc4 <trap+0x27b>
80106bae:	8b 45 08             	mov    0x8(%ebp),%eax
80106bb1:	8b 40 3c             	mov    0x3c(%eax),%eax
80106bb4:	0f b7 c0             	movzwl %ax,%eax
80106bb7:	83 e0 03             	and    $0x3,%eax
80106bba:	83 f8 03             	cmp    $0x3,%eax
80106bbd:	75 05                	jne    80106bc4 <trap+0x27b>
    exit();
80106bbf:	e8 4a db ff ff       	call   8010470e <exit>
}
80106bc4:	83 c4 4c             	add    $0x4c,%esp
80106bc7:	5b                   	pop    %ebx
80106bc8:	5e                   	pop    %esi
80106bc9:	5f                   	pop    %edi
80106bca:	5d                   	pop    %ebp
80106bcb:	c3                   	ret    

80106bcc <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106bcc:	55                   	push   %ebp
80106bcd:	89 e5                	mov    %esp,%ebp
80106bcf:	83 ec 14             	sub    $0x14,%esp
80106bd2:	8b 45 08             	mov    0x8(%ebp),%eax
80106bd5:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106bd9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106bdc:	89 c2                	mov    %eax,%edx
80106bde:	ec                   	in     (%dx),%al
80106bdf:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106be2:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80106be5:	c9                   	leave  
80106be6:	c3                   	ret    

80106be7 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106be7:	55                   	push   %ebp
80106be8:	89 e5                	mov    %esp,%ebp
80106bea:	83 ec 08             	sub    $0x8,%esp
80106bed:	8b 45 08             	mov    0x8(%ebp),%eax
80106bf0:	8b 55 0c             	mov    0xc(%ebp),%edx
80106bf3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106bf7:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106bfa:	8a 45 f8             	mov    -0x8(%ebp),%al
80106bfd:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106c00:	ee                   	out    %al,(%dx)
}
80106c01:	c9                   	leave  
80106c02:	c3                   	ret    

80106c03 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106c03:	55                   	push   %ebp
80106c04:	89 e5                	mov    %esp,%ebp
80106c06:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106c09:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106c10:	00 
80106c11:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106c18:	e8 ca ff ff ff       	call   80106be7 <outb>

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106c1d:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80106c24:	00 
80106c25:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106c2c:	e8 b6 ff ff ff       	call   80106be7 <outb>
  outb(COM1+0, 115200/9600);
80106c31:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80106c38:	00 
80106c39:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106c40:	e8 a2 ff ff ff       	call   80106be7 <outb>
  outb(COM1+1, 0);
80106c45:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106c4c:	00 
80106c4d:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106c54:	e8 8e ff ff ff       	call   80106be7 <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106c59:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106c60:	00 
80106c61:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106c68:	e8 7a ff ff ff       	call   80106be7 <outb>
  outb(COM1+4, 0);
80106c6d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106c74:	00 
80106c75:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80106c7c:	e8 66 ff ff ff       	call   80106be7 <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106c81:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106c88:	00 
80106c89:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106c90:	e8 52 ff ff ff       	call   80106be7 <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106c95:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106c9c:	e8 2b ff ff ff       	call   80106bcc <inb>
80106ca1:	3c ff                	cmp    $0xff,%al
80106ca3:	75 02                	jne    80106ca7 <uartinit+0xa4>
    return;
80106ca5:	eb 5b                	jmp    80106d02 <uartinit+0xff>
  uart = 1;
80106ca7:	c7 05 c4 b8 10 80 01 	movl   $0x1,0x8010b8c4
80106cae:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106cb1:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106cb8:	e8 0f ff ff ff       	call   80106bcc <inb>
  inb(COM1+0);
80106cbd:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106cc4:	e8 03 ff ff ff       	call   80106bcc <inb>
  ioapicenable(IRQ_COM1, 0);
80106cc9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106cd0:	00 
80106cd1:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106cd8:	e8 96 be ff ff       	call   80102b73 <ioapicenable>

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106cdd:	c7 45 f4 c4 8e 10 80 	movl   $0x80108ec4,-0xc(%ebp)
80106ce4:	eb 13                	jmp    80106cf9 <uartinit+0xf6>
    uartputc(*p);
80106ce6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ce9:	8a 00                	mov    (%eax),%al
80106ceb:	0f be c0             	movsbl %al,%eax
80106cee:	89 04 24             	mov    %eax,(%esp)
80106cf1:	e8 0e 00 00 00       	call   80106d04 <uartputc>
  inb(COM1+2);
  inb(COM1+0);
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106cf6:	ff 45 f4             	incl   -0xc(%ebp)
80106cf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106cfc:	8a 00                	mov    (%eax),%al
80106cfe:	84 c0                	test   %al,%al
80106d00:	75 e4                	jne    80106ce6 <uartinit+0xe3>
    uartputc(*p);
}
80106d02:	c9                   	leave  
80106d03:	c3                   	ret    

80106d04 <uartputc>:

void
uartputc(int c)
{
80106d04:	55                   	push   %ebp
80106d05:	89 e5                	mov    %esp,%ebp
80106d07:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80106d0a:	a1 c4 b8 10 80       	mov    0x8010b8c4,%eax
80106d0f:	85 c0                	test   %eax,%eax
80106d11:	75 02                	jne    80106d15 <uartputc+0x11>
    return;
80106d13:	eb 4a                	jmp    80106d5f <uartputc+0x5b>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106d15:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106d1c:	eb 0f                	jmp    80106d2d <uartputc+0x29>
    microdelay(10);
80106d1e:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80106d25:	e8 7a c3 ff ff       	call   801030a4 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106d2a:	ff 45 f4             	incl   -0xc(%ebp)
80106d2d:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106d31:	7f 16                	jg     80106d49 <uartputc+0x45>
80106d33:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106d3a:	e8 8d fe ff ff       	call   80106bcc <inb>
80106d3f:	0f b6 c0             	movzbl %al,%eax
80106d42:	83 e0 20             	and    $0x20,%eax
80106d45:	85 c0                	test   %eax,%eax
80106d47:	74 d5                	je     80106d1e <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
80106d49:	8b 45 08             	mov    0x8(%ebp),%eax
80106d4c:	0f b6 c0             	movzbl %al,%eax
80106d4f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d53:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106d5a:	e8 88 fe ff ff       	call   80106be7 <outb>
}
80106d5f:	c9                   	leave  
80106d60:	c3                   	ret    

80106d61 <uartgetc>:

static int
uartgetc(void)
{
80106d61:	55                   	push   %ebp
80106d62:	89 e5                	mov    %esp,%ebp
80106d64:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80106d67:	a1 c4 b8 10 80       	mov    0x8010b8c4,%eax
80106d6c:	85 c0                	test   %eax,%eax
80106d6e:	75 07                	jne    80106d77 <uartgetc+0x16>
    return -1;
80106d70:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d75:	eb 2c                	jmp    80106da3 <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80106d77:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106d7e:	e8 49 fe ff ff       	call   80106bcc <inb>
80106d83:	0f b6 c0             	movzbl %al,%eax
80106d86:	83 e0 01             	and    $0x1,%eax
80106d89:	85 c0                	test   %eax,%eax
80106d8b:	75 07                	jne    80106d94 <uartgetc+0x33>
    return -1;
80106d8d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d92:	eb 0f                	jmp    80106da3 <uartgetc+0x42>
  return inb(COM1+0);
80106d94:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106d9b:	e8 2c fe ff ff       	call   80106bcc <inb>
80106da0:	0f b6 c0             	movzbl %al,%eax
}
80106da3:	c9                   	leave  
80106da4:	c3                   	ret    

80106da5 <uartintr>:

void
uartintr(void)
{
80106da5:	55                   	push   %ebp
80106da6:	89 e5                	mov    %esp,%ebp
80106da8:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80106dab:	c7 04 24 61 6d 10 80 	movl   $0x80106d61,(%esp)
80106db2:	e8 3e 9a ff ff       	call   801007f5 <consoleintr>
}
80106db7:	c9                   	leave  
80106db8:	c3                   	ret    
80106db9:	00 00                	add    %al,(%eax)
	...

80106dbc <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106dbc:	6a 00                	push   $0x0
  pushl $0
80106dbe:	6a 00                	push   $0x0
  jmp alltraps
80106dc0:	e9 af f9 ff ff       	jmp    80106774 <alltraps>

80106dc5 <vector1>:
.globl vector1
vector1:
  pushl $0
80106dc5:	6a 00                	push   $0x0
  pushl $1
80106dc7:	6a 01                	push   $0x1
  jmp alltraps
80106dc9:	e9 a6 f9 ff ff       	jmp    80106774 <alltraps>

80106dce <vector2>:
.globl vector2
vector2:
  pushl $0
80106dce:	6a 00                	push   $0x0
  pushl $2
80106dd0:	6a 02                	push   $0x2
  jmp alltraps
80106dd2:	e9 9d f9 ff ff       	jmp    80106774 <alltraps>

80106dd7 <vector3>:
.globl vector3
vector3:
  pushl $0
80106dd7:	6a 00                	push   $0x0
  pushl $3
80106dd9:	6a 03                	push   $0x3
  jmp alltraps
80106ddb:	e9 94 f9 ff ff       	jmp    80106774 <alltraps>

80106de0 <vector4>:
.globl vector4
vector4:
  pushl $0
80106de0:	6a 00                	push   $0x0
  pushl $4
80106de2:	6a 04                	push   $0x4
  jmp alltraps
80106de4:	e9 8b f9 ff ff       	jmp    80106774 <alltraps>

80106de9 <vector5>:
.globl vector5
vector5:
  pushl $0
80106de9:	6a 00                	push   $0x0
  pushl $5
80106deb:	6a 05                	push   $0x5
  jmp alltraps
80106ded:	e9 82 f9 ff ff       	jmp    80106774 <alltraps>

80106df2 <vector6>:
.globl vector6
vector6:
  pushl $0
80106df2:	6a 00                	push   $0x0
  pushl $6
80106df4:	6a 06                	push   $0x6
  jmp alltraps
80106df6:	e9 79 f9 ff ff       	jmp    80106774 <alltraps>

80106dfb <vector7>:
.globl vector7
vector7:
  pushl $0
80106dfb:	6a 00                	push   $0x0
  pushl $7
80106dfd:	6a 07                	push   $0x7
  jmp alltraps
80106dff:	e9 70 f9 ff ff       	jmp    80106774 <alltraps>

80106e04 <vector8>:
.globl vector8
vector8:
  pushl $8
80106e04:	6a 08                	push   $0x8
  jmp alltraps
80106e06:	e9 69 f9 ff ff       	jmp    80106774 <alltraps>

80106e0b <vector9>:
.globl vector9
vector9:
  pushl $0
80106e0b:	6a 00                	push   $0x0
  pushl $9
80106e0d:	6a 09                	push   $0x9
  jmp alltraps
80106e0f:	e9 60 f9 ff ff       	jmp    80106774 <alltraps>

80106e14 <vector10>:
.globl vector10
vector10:
  pushl $10
80106e14:	6a 0a                	push   $0xa
  jmp alltraps
80106e16:	e9 59 f9 ff ff       	jmp    80106774 <alltraps>

80106e1b <vector11>:
.globl vector11
vector11:
  pushl $11
80106e1b:	6a 0b                	push   $0xb
  jmp alltraps
80106e1d:	e9 52 f9 ff ff       	jmp    80106774 <alltraps>

80106e22 <vector12>:
.globl vector12
vector12:
  pushl $12
80106e22:	6a 0c                	push   $0xc
  jmp alltraps
80106e24:	e9 4b f9 ff ff       	jmp    80106774 <alltraps>

80106e29 <vector13>:
.globl vector13
vector13:
  pushl $13
80106e29:	6a 0d                	push   $0xd
  jmp alltraps
80106e2b:	e9 44 f9 ff ff       	jmp    80106774 <alltraps>

80106e30 <vector14>:
.globl vector14
vector14:
  pushl $14
80106e30:	6a 0e                	push   $0xe
  jmp alltraps
80106e32:	e9 3d f9 ff ff       	jmp    80106774 <alltraps>

80106e37 <vector15>:
.globl vector15
vector15:
  pushl $0
80106e37:	6a 00                	push   $0x0
  pushl $15
80106e39:	6a 0f                	push   $0xf
  jmp alltraps
80106e3b:	e9 34 f9 ff ff       	jmp    80106774 <alltraps>

80106e40 <vector16>:
.globl vector16
vector16:
  pushl $0
80106e40:	6a 00                	push   $0x0
  pushl $16
80106e42:	6a 10                	push   $0x10
  jmp alltraps
80106e44:	e9 2b f9 ff ff       	jmp    80106774 <alltraps>

80106e49 <vector17>:
.globl vector17
vector17:
  pushl $17
80106e49:	6a 11                	push   $0x11
  jmp alltraps
80106e4b:	e9 24 f9 ff ff       	jmp    80106774 <alltraps>

80106e50 <vector18>:
.globl vector18
vector18:
  pushl $0
80106e50:	6a 00                	push   $0x0
  pushl $18
80106e52:	6a 12                	push   $0x12
  jmp alltraps
80106e54:	e9 1b f9 ff ff       	jmp    80106774 <alltraps>

80106e59 <vector19>:
.globl vector19
vector19:
  pushl $0
80106e59:	6a 00                	push   $0x0
  pushl $19
80106e5b:	6a 13                	push   $0x13
  jmp alltraps
80106e5d:	e9 12 f9 ff ff       	jmp    80106774 <alltraps>

80106e62 <vector20>:
.globl vector20
vector20:
  pushl $0
80106e62:	6a 00                	push   $0x0
  pushl $20
80106e64:	6a 14                	push   $0x14
  jmp alltraps
80106e66:	e9 09 f9 ff ff       	jmp    80106774 <alltraps>

80106e6b <vector21>:
.globl vector21
vector21:
  pushl $0
80106e6b:	6a 00                	push   $0x0
  pushl $21
80106e6d:	6a 15                	push   $0x15
  jmp alltraps
80106e6f:	e9 00 f9 ff ff       	jmp    80106774 <alltraps>

80106e74 <vector22>:
.globl vector22
vector22:
  pushl $0
80106e74:	6a 00                	push   $0x0
  pushl $22
80106e76:	6a 16                	push   $0x16
  jmp alltraps
80106e78:	e9 f7 f8 ff ff       	jmp    80106774 <alltraps>

80106e7d <vector23>:
.globl vector23
vector23:
  pushl $0
80106e7d:	6a 00                	push   $0x0
  pushl $23
80106e7f:	6a 17                	push   $0x17
  jmp alltraps
80106e81:	e9 ee f8 ff ff       	jmp    80106774 <alltraps>

80106e86 <vector24>:
.globl vector24
vector24:
  pushl $0
80106e86:	6a 00                	push   $0x0
  pushl $24
80106e88:	6a 18                	push   $0x18
  jmp alltraps
80106e8a:	e9 e5 f8 ff ff       	jmp    80106774 <alltraps>

80106e8f <vector25>:
.globl vector25
vector25:
  pushl $0
80106e8f:	6a 00                	push   $0x0
  pushl $25
80106e91:	6a 19                	push   $0x19
  jmp alltraps
80106e93:	e9 dc f8 ff ff       	jmp    80106774 <alltraps>

80106e98 <vector26>:
.globl vector26
vector26:
  pushl $0
80106e98:	6a 00                	push   $0x0
  pushl $26
80106e9a:	6a 1a                	push   $0x1a
  jmp alltraps
80106e9c:	e9 d3 f8 ff ff       	jmp    80106774 <alltraps>

80106ea1 <vector27>:
.globl vector27
vector27:
  pushl $0
80106ea1:	6a 00                	push   $0x0
  pushl $27
80106ea3:	6a 1b                	push   $0x1b
  jmp alltraps
80106ea5:	e9 ca f8 ff ff       	jmp    80106774 <alltraps>

80106eaa <vector28>:
.globl vector28
vector28:
  pushl $0
80106eaa:	6a 00                	push   $0x0
  pushl $28
80106eac:	6a 1c                	push   $0x1c
  jmp alltraps
80106eae:	e9 c1 f8 ff ff       	jmp    80106774 <alltraps>

80106eb3 <vector29>:
.globl vector29
vector29:
  pushl $0
80106eb3:	6a 00                	push   $0x0
  pushl $29
80106eb5:	6a 1d                	push   $0x1d
  jmp alltraps
80106eb7:	e9 b8 f8 ff ff       	jmp    80106774 <alltraps>

80106ebc <vector30>:
.globl vector30
vector30:
  pushl $0
80106ebc:	6a 00                	push   $0x0
  pushl $30
80106ebe:	6a 1e                	push   $0x1e
  jmp alltraps
80106ec0:	e9 af f8 ff ff       	jmp    80106774 <alltraps>

80106ec5 <vector31>:
.globl vector31
vector31:
  pushl $0
80106ec5:	6a 00                	push   $0x0
  pushl $31
80106ec7:	6a 1f                	push   $0x1f
  jmp alltraps
80106ec9:	e9 a6 f8 ff ff       	jmp    80106774 <alltraps>

80106ece <vector32>:
.globl vector32
vector32:
  pushl $0
80106ece:	6a 00                	push   $0x0
  pushl $32
80106ed0:	6a 20                	push   $0x20
  jmp alltraps
80106ed2:	e9 9d f8 ff ff       	jmp    80106774 <alltraps>

80106ed7 <vector33>:
.globl vector33
vector33:
  pushl $0
80106ed7:	6a 00                	push   $0x0
  pushl $33
80106ed9:	6a 21                	push   $0x21
  jmp alltraps
80106edb:	e9 94 f8 ff ff       	jmp    80106774 <alltraps>

80106ee0 <vector34>:
.globl vector34
vector34:
  pushl $0
80106ee0:	6a 00                	push   $0x0
  pushl $34
80106ee2:	6a 22                	push   $0x22
  jmp alltraps
80106ee4:	e9 8b f8 ff ff       	jmp    80106774 <alltraps>

80106ee9 <vector35>:
.globl vector35
vector35:
  pushl $0
80106ee9:	6a 00                	push   $0x0
  pushl $35
80106eeb:	6a 23                	push   $0x23
  jmp alltraps
80106eed:	e9 82 f8 ff ff       	jmp    80106774 <alltraps>

80106ef2 <vector36>:
.globl vector36
vector36:
  pushl $0
80106ef2:	6a 00                	push   $0x0
  pushl $36
80106ef4:	6a 24                	push   $0x24
  jmp alltraps
80106ef6:	e9 79 f8 ff ff       	jmp    80106774 <alltraps>

80106efb <vector37>:
.globl vector37
vector37:
  pushl $0
80106efb:	6a 00                	push   $0x0
  pushl $37
80106efd:	6a 25                	push   $0x25
  jmp alltraps
80106eff:	e9 70 f8 ff ff       	jmp    80106774 <alltraps>

80106f04 <vector38>:
.globl vector38
vector38:
  pushl $0
80106f04:	6a 00                	push   $0x0
  pushl $38
80106f06:	6a 26                	push   $0x26
  jmp alltraps
80106f08:	e9 67 f8 ff ff       	jmp    80106774 <alltraps>

80106f0d <vector39>:
.globl vector39
vector39:
  pushl $0
80106f0d:	6a 00                	push   $0x0
  pushl $39
80106f0f:	6a 27                	push   $0x27
  jmp alltraps
80106f11:	e9 5e f8 ff ff       	jmp    80106774 <alltraps>

80106f16 <vector40>:
.globl vector40
vector40:
  pushl $0
80106f16:	6a 00                	push   $0x0
  pushl $40
80106f18:	6a 28                	push   $0x28
  jmp alltraps
80106f1a:	e9 55 f8 ff ff       	jmp    80106774 <alltraps>

80106f1f <vector41>:
.globl vector41
vector41:
  pushl $0
80106f1f:	6a 00                	push   $0x0
  pushl $41
80106f21:	6a 29                	push   $0x29
  jmp alltraps
80106f23:	e9 4c f8 ff ff       	jmp    80106774 <alltraps>

80106f28 <vector42>:
.globl vector42
vector42:
  pushl $0
80106f28:	6a 00                	push   $0x0
  pushl $42
80106f2a:	6a 2a                	push   $0x2a
  jmp alltraps
80106f2c:	e9 43 f8 ff ff       	jmp    80106774 <alltraps>

80106f31 <vector43>:
.globl vector43
vector43:
  pushl $0
80106f31:	6a 00                	push   $0x0
  pushl $43
80106f33:	6a 2b                	push   $0x2b
  jmp alltraps
80106f35:	e9 3a f8 ff ff       	jmp    80106774 <alltraps>

80106f3a <vector44>:
.globl vector44
vector44:
  pushl $0
80106f3a:	6a 00                	push   $0x0
  pushl $44
80106f3c:	6a 2c                	push   $0x2c
  jmp alltraps
80106f3e:	e9 31 f8 ff ff       	jmp    80106774 <alltraps>

80106f43 <vector45>:
.globl vector45
vector45:
  pushl $0
80106f43:	6a 00                	push   $0x0
  pushl $45
80106f45:	6a 2d                	push   $0x2d
  jmp alltraps
80106f47:	e9 28 f8 ff ff       	jmp    80106774 <alltraps>

80106f4c <vector46>:
.globl vector46
vector46:
  pushl $0
80106f4c:	6a 00                	push   $0x0
  pushl $46
80106f4e:	6a 2e                	push   $0x2e
  jmp alltraps
80106f50:	e9 1f f8 ff ff       	jmp    80106774 <alltraps>

80106f55 <vector47>:
.globl vector47
vector47:
  pushl $0
80106f55:	6a 00                	push   $0x0
  pushl $47
80106f57:	6a 2f                	push   $0x2f
  jmp alltraps
80106f59:	e9 16 f8 ff ff       	jmp    80106774 <alltraps>

80106f5e <vector48>:
.globl vector48
vector48:
  pushl $0
80106f5e:	6a 00                	push   $0x0
  pushl $48
80106f60:	6a 30                	push   $0x30
  jmp alltraps
80106f62:	e9 0d f8 ff ff       	jmp    80106774 <alltraps>

80106f67 <vector49>:
.globl vector49
vector49:
  pushl $0
80106f67:	6a 00                	push   $0x0
  pushl $49
80106f69:	6a 31                	push   $0x31
  jmp alltraps
80106f6b:	e9 04 f8 ff ff       	jmp    80106774 <alltraps>

80106f70 <vector50>:
.globl vector50
vector50:
  pushl $0
80106f70:	6a 00                	push   $0x0
  pushl $50
80106f72:	6a 32                	push   $0x32
  jmp alltraps
80106f74:	e9 fb f7 ff ff       	jmp    80106774 <alltraps>

80106f79 <vector51>:
.globl vector51
vector51:
  pushl $0
80106f79:	6a 00                	push   $0x0
  pushl $51
80106f7b:	6a 33                	push   $0x33
  jmp alltraps
80106f7d:	e9 f2 f7 ff ff       	jmp    80106774 <alltraps>

80106f82 <vector52>:
.globl vector52
vector52:
  pushl $0
80106f82:	6a 00                	push   $0x0
  pushl $52
80106f84:	6a 34                	push   $0x34
  jmp alltraps
80106f86:	e9 e9 f7 ff ff       	jmp    80106774 <alltraps>

80106f8b <vector53>:
.globl vector53
vector53:
  pushl $0
80106f8b:	6a 00                	push   $0x0
  pushl $53
80106f8d:	6a 35                	push   $0x35
  jmp alltraps
80106f8f:	e9 e0 f7 ff ff       	jmp    80106774 <alltraps>

80106f94 <vector54>:
.globl vector54
vector54:
  pushl $0
80106f94:	6a 00                	push   $0x0
  pushl $54
80106f96:	6a 36                	push   $0x36
  jmp alltraps
80106f98:	e9 d7 f7 ff ff       	jmp    80106774 <alltraps>

80106f9d <vector55>:
.globl vector55
vector55:
  pushl $0
80106f9d:	6a 00                	push   $0x0
  pushl $55
80106f9f:	6a 37                	push   $0x37
  jmp alltraps
80106fa1:	e9 ce f7 ff ff       	jmp    80106774 <alltraps>

80106fa6 <vector56>:
.globl vector56
vector56:
  pushl $0
80106fa6:	6a 00                	push   $0x0
  pushl $56
80106fa8:	6a 38                	push   $0x38
  jmp alltraps
80106faa:	e9 c5 f7 ff ff       	jmp    80106774 <alltraps>

80106faf <vector57>:
.globl vector57
vector57:
  pushl $0
80106faf:	6a 00                	push   $0x0
  pushl $57
80106fb1:	6a 39                	push   $0x39
  jmp alltraps
80106fb3:	e9 bc f7 ff ff       	jmp    80106774 <alltraps>

80106fb8 <vector58>:
.globl vector58
vector58:
  pushl $0
80106fb8:	6a 00                	push   $0x0
  pushl $58
80106fba:	6a 3a                	push   $0x3a
  jmp alltraps
80106fbc:	e9 b3 f7 ff ff       	jmp    80106774 <alltraps>

80106fc1 <vector59>:
.globl vector59
vector59:
  pushl $0
80106fc1:	6a 00                	push   $0x0
  pushl $59
80106fc3:	6a 3b                	push   $0x3b
  jmp alltraps
80106fc5:	e9 aa f7 ff ff       	jmp    80106774 <alltraps>

80106fca <vector60>:
.globl vector60
vector60:
  pushl $0
80106fca:	6a 00                	push   $0x0
  pushl $60
80106fcc:	6a 3c                	push   $0x3c
  jmp alltraps
80106fce:	e9 a1 f7 ff ff       	jmp    80106774 <alltraps>

80106fd3 <vector61>:
.globl vector61
vector61:
  pushl $0
80106fd3:	6a 00                	push   $0x0
  pushl $61
80106fd5:	6a 3d                	push   $0x3d
  jmp alltraps
80106fd7:	e9 98 f7 ff ff       	jmp    80106774 <alltraps>

80106fdc <vector62>:
.globl vector62
vector62:
  pushl $0
80106fdc:	6a 00                	push   $0x0
  pushl $62
80106fde:	6a 3e                	push   $0x3e
  jmp alltraps
80106fe0:	e9 8f f7 ff ff       	jmp    80106774 <alltraps>

80106fe5 <vector63>:
.globl vector63
vector63:
  pushl $0
80106fe5:	6a 00                	push   $0x0
  pushl $63
80106fe7:	6a 3f                	push   $0x3f
  jmp alltraps
80106fe9:	e9 86 f7 ff ff       	jmp    80106774 <alltraps>

80106fee <vector64>:
.globl vector64
vector64:
  pushl $0
80106fee:	6a 00                	push   $0x0
  pushl $64
80106ff0:	6a 40                	push   $0x40
  jmp alltraps
80106ff2:	e9 7d f7 ff ff       	jmp    80106774 <alltraps>

80106ff7 <vector65>:
.globl vector65
vector65:
  pushl $0
80106ff7:	6a 00                	push   $0x0
  pushl $65
80106ff9:	6a 41                	push   $0x41
  jmp alltraps
80106ffb:	e9 74 f7 ff ff       	jmp    80106774 <alltraps>

80107000 <vector66>:
.globl vector66
vector66:
  pushl $0
80107000:	6a 00                	push   $0x0
  pushl $66
80107002:	6a 42                	push   $0x42
  jmp alltraps
80107004:	e9 6b f7 ff ff       	jmp    80106774 <alltraps>

80107009 <vector67>:
.globl vector67
vector67:
  pushl $0
80107009:	6a 00                	push   $0x0
  pushl $67
8010700b:	6a 43                	push   $0x43
  jmp alltraps
8010700d:	e9 62 f7 ff ff       	jmp    80106774 <alltraps>

80107012 <vector68>:
.globl vector68
vector68:
  pushl $0
80107012:	6a 00                	push   $0x0
  pushl $68
80107014:	6a 44                	push   $0x44
  jmp alltraps
80107016:	e9 59 f7 ff ff       	jmp    80106774 <alltraps>

8010701b <vector69>:
.globl vector69
vector69:
  pushl $0
8010701b:	6a 00                	push   $0x0
  pushl $69
8010701d:	6a 45                	push   $0x45
  jmp alltraps
8010701f:	e9 50 f7 ff ff       	jmp    80106774 <alltraps>

80107024 <vector70>:
.globl vector70
vector70:
  pushl $0
80107024:	6a 00                	push   $0x0
  pushl $70
80107026:	6a 46                	push   $0x46
  jmp alltraps
80107028:	e9 47 f7 ff ff       	jmp    80106774 <alltraps>

8010702d <vector71>:
.globl vector71
vector71:
  pushl $0
8010702d:	6a 00                	push   $0x0
  pushl $71
8010702f:	6a 47                	push   $0x47
  jmp alltraps
80107031:	e9 3e f7 ff ff       	jmp    80106774 <alltraps>

80107036 <vector72>:
.globl vector72
vector72:
  pushl $0
80107036:	6a 00                	push   $0x0
  pushl $72
80107038:	6a 48                	push   $0x48
  jmp alltraps
8010703a:	e9 35 f7 ff ff       	jmp    80106774 <alltraps>

8010703f <vector73>:
.globl vector73
vector73:
  pushl $0
8010703f:	6a 00                	push   $0x0
  pushl $73
80107041:	6a 49                	push   $0x49
  jmp alltraps
80107043:	e9 2c f7 ff ff       	jmp    80106774 <alltraps>

80107048 <vector74>:
.globl vector74
vector74:
  pushl $0
80107048:	6a 00                	push   $0x0
  pushl $74
8010704a:	6a 4a                	push   $0x4a
  jmp alltraps
8010704c:	e9 23 f7 ff ff       	jmp    80106774 <alltraps>

80107051 <vector75>:
.globl vector75
vector75:
  pushl $0
80107051:	6a 00                	push   $0x0
  pushl $75
80107053:	6a 4b                	push   $0x4b
  jmp alltraps
80107055:	e9 1a f7 ff ff       	jmp    80106774 <alltraps>

8010705a <vector76>:
.globl vector76
vector76:
  pushl $0
8010705a:	6a 00                	push   $0x0
  pushl $76
8010705c:	6a 4c                	push   $0x4c
  jmp alltraps
8010705e:	e9 11 f7 ff ff       	jmp    80106774 <alltraps>

80107063 <vector77>:
.globl vector77
vector77:
  pushl $0
80107063:	6a 00                	push   $0x0
  pushl $77
80107065:	6a 4d                	push   $0x4d
  jmp alltraps
80107067:	e9 08 f7 ff ff       	jmp    80106774 <alltraps>

8010706c <vector78>:
.globl vector78
vector78:
  pushl $0
8010706c:	6a 00                	push   $0x0
  pushl $78
8010706e:	6a 4e                	push   $0x4e
  jmp alltraps
80107070:	e9 ff f6 ff ff       	jmp    80106774 <alltraps>

80107075 <vector79>:
.globl vector79
vector79:
  pushl $0
80107075:	6a 00                	push   $0x0
  pushl $79
80107077:	6a 4f                	push   $0x4f
  jmp alltraps
80107079:	e9 f6 f6 ff ff       	jmp    80106774 <alltraps>

8010707e <vector80>:
.globl vector80
vector80:
  pushl $0
8010707e:	6a 00                	push   $0x0
  pushl $80
80107080:	6a 50                	push   $0x50
  jmp alltraps
80107082:	e9 ed f6 ff ff       	jmp    80106774 <alltraps>

80107087 <vector81>:
.globl vector81
vector81:
  pushl $0
80107087:	6a 00                	push   $0x0
  pushl $81
80107089:	6a 51                	push   $0x51
  jmp alltraps
8010708b:	e9 e4 f6 ff ff       	jmp    80106774 <alltraps>

80107090 <vector82>:
.globl vector82
vector82:
  pushl $0
80107090:	6a 00                	push   $0x0
  pushl $82
80107092:	6a 52                	push   $0x52
  jmp alltraps
80107094:	e9 db f6 ff ff       	jmp    80106774 <alltraps>

80107099 <vector83>:
.globl vector83
vector83:
  pushl $0
80107099:	6a 00                	push   $0x0
  pushl $83
8010709b:	6a 53                	push   $0x53
  jmp alltraps
8010709d:	e9 d2 f6 ff ff       	jmp    80106774 <alltraps>

801070a2 <vector84>:
.globl vector84
vector84:
  pushl $0
801070a2:	6a 00                	push   $0x0
  pushl $84
801070a4:	6a 54                	push   $0x54
  jmp alltraps
801070a6:	e9 c9 f6 ff ff       	jmp    80106774 <alltraps>

801070ab <vector85>:
.globl vector85
vector85:
  pushl $0
801070ab:	6a 00                	push   $0x0
  pushl $85
801070ad:	6a 55                	push   $0x55
  jmp alltraps
801070af:	e9 c0 f6 ff ff       	jmp    80106774 <alltraps>

801070b4 <vector86>:
.globl vector86
vector86:
  pushl $0
801070b4:	6a 00                	push   $0x0
  pushl $86
801070b6:	6a 56                	push   $0x56
  jmp alltraps
801070b8:	e9 b7 f6 ff ff       	jmp    80106774 <alltraps>

801070bd <vector87>:
.globl vector87
vector87:
  pushl $0
801070bd:	6a 00                	push   $0x0
  pushl $87
801070bf:	6a 57                	push   $0x57
  jmp alltraps
801070c1:	e9 ae f6 ff ff       	jmp    80106774 <alltraps>

801070c6 <vector88>:
.globl vector88
vector88:
  pushl $0
801070c6:	6a 00                	push   $0x0
  pushl $88
801070c8:	6a 58                	push   $0x58
  jmp alltraps
801070ca:	e9 a5 f6 ff ff       	jmp    80106774 <alltraps>

801070cf <vector89>:
.globl vector89
vector89:
  pushl $0
801070cf:	6a 00                	push   $0x0
  pushl $89
801070d1:	6a 59                	push   $0x59
  jmp alltraps
801070d3:	e9 9c f6 ff ff       	jmp    80106774 <alltraps>

801070d8 <vector90>:
.globl vector90
vector90:
  pushl $0
801070d8:	6a 00                	push   $0x0
  pushl $90
801070da:	6a 5a                	push   $0x5a
  jmp alltraps
801070dc:	e9 93 f6 ff ff       	jmp    80106774 <alltraps>

801070e1 <vector91>:
.globl vector91
vector91:
  pushl $0
801070e1:	6a 00                	push   $0x0
  pushl $91
801070e3:	6a 5b                	push   $0x5b
  jmp alltraps
801070e5:	e9 8a f6 ff ff       	jmp    80106774 <alltraps>

801070ea <vector92>:
.globl vector92
vector92:
  pushl $0
801070ea:	6a 00                	push   $0x0
  pushl $92
801070ec:	6a 5c                	push   $0x5c
  jmp alltraps
801070ee:	e9 81 f6 ff ff       	jmp    80106774 <alltraps>

801070f3 <vector93>:
.globl vector93
vector93:
  pushl $0
801070f3:	6a 00                	push   $0x0
  pushl $93
801070f5:	6a 5d                	push   $0x5d
  jmp alltraps
801070f7:	e9 78 f6 ff ff       	jmp    80106774 <alltraps>

801070fc <vector94>:
.globl vector94
vector94:
  pushl $0
801070fc:	6a 00                	push   $0x0
  pushl $94
801070fe:	6a 5e                	push   $0x5e
  jmp alltraps
80107100:	e9 6f f6 ff ff       	jmp    80106774 <alltraps>

80107105 <vector95>:
.globl vector95
vector95:
  pushl $0
80107105:	6a 00                	push   $0x0
  pushl $95
80107107:	6a 5f                	push   $0x5f
  jmp alltraps
80107109:	e9 66 f6 ff ff       	jmp    80106774 <alltraps>

8010710e <vector96>:
.globl vector96
vector96:
  pushl $0
8010710e:	6a 00                	push   $0x0
  pushl $96
80107110:	6a 60                	push   $0x60
  jmp alltraps
80107112:	e9 5d f6 ff ff       	jmp    80106774 <alltraps>

80107117 <vector97>:
.globl vector97
vector97:
  pushl $0
80107117:	6a 00                	push   $0x0
  pushl $97
80107119:	6a 61                	push   $0x61
  jmp alltraps
8010711b:	e9 54 f6 ff ff       	jmp    80106774 <alltraps>

80107120 <vector98>:
.globl vector98
vector98:
  pushl $0
80107120:	6a 00                	push   $0x0
  pushl $98
80107122:	6a 62                	push   $0x62
  jmp alltraps
80107124:	e9 4b f6 ff ff       	jmp    80106774 <alltraps>

80107129 <vector99>:
.globl vector99
vector99:
  pushl $0
80107129:	6a 00                	push   $0x0
  pushl $99
8010712b:	6a 63                	push   $0x63
  jmp alltraps
8010712d:	e9 42 f6 ff ff       	jmp    80106774 <alltraps>

80107132 <vector100>:
.globl vector100
vector100:
  pushl $0
80107132:	6a 00                	push   $0x0
  pushl $100
80107134:	6a 64                	push   $0x64
  jmp alltraps
80107136:	e9 39 f6 ff ff       	jmp    80106774 <alltraps>

8010713b <vector101>:
.globl vector101
vector101:
  pushl $0
8010713b:	6a 00                	push   $0x0
  pushl $101
8010713d:	6a 65                	push   $0x65
  jmp alltraps
8010713f:	e9 30 f6 ff ff       	jmp    80106774 <alltraps>

80107144 <vector102>:
.globl vector102
vector102:
  pushl $0
80107144:	6a 00                	push   $0x0
  pushl $102
80107146:	6a 66                	push   $0x66
  jmp alltraps
80107148:	e9 27 f6 ff ff       	jmp    80106774 <alltraps>

8010714d <vector103>:
.globl vector103
vector103:
  pushl $0
8010714d:	6a 00                	push   $0x0
  pushl $103
8010714f:	6a 67                	push   $0x67
  jmp alltraps
80107151:	e9 1e f6 ff ff       	jmp    80106774 <alltraps>

80107156 <vector104>:
.globl vector104
vector104:
  pushl $0
80107156:	6a 00                	push   $0x0
  pushl $104
80107158:	6a 68                	push   $0x68
  jmp alltraps
8010715a:	e9 15 f6 ff ff       	jmp    80106774 <alltraps>

8010715f <vector105>:
.globl vector105
vector105:
  pushl $0
8010715f:	6a 00                	push   $0x0
  pushl $105
80107161:	6a 69                	push   $0x69
  jmp alltraps
80107163:	e9 0c f6 ff ff       	jmp    80106774 <alltraps>

80107168 <vector106>:
.globl vector106
vector106:
  pushl $0
80107168:	6a 00                	push   $0x0
  pushl $106
8010716a:	6a 6a                	push   $0x6a
  jmp alltraps
8010716c:	e9 03 f6 ff ff       	jmp    80106774 <alltraps>

80107171 <vector107>:
.globl vector107
vector107:
  pushl $0
80107171:	6a 00                	push   $0x0
  pushl $107
80107173:	6a 6b                	push   $0x6b
  jmp alltraps
80107175:	e9 fa f5 ff ff       	jmp    80106774 <alltraps>

8010717a <vector108>:
.globl vector108
vector108:
  pushl $0
8010717a:	6a 00                	push   $0x0
  pushl $108
8010717c:	6a 6c                	push   $0x6c
  jmp alltraps
8010717e:	e9 f1 f5 ff ff       	jmp    80106774 <alltraps>

80107183 <vector109>:
.globl vector109
vector109:
  pushl $0
80107183:	6a 00                	push   $0x0
  pushl $109
80107185:	6a 6d                	push   $0x6d
  jmp alltraps
80107187:	e9 e8 f5 ff ff       	jmp    80106774 <alltraps>

8010718c <vector110>:
.globl vector110
vector110:
  pushl $0
8010718c:	6a 00                	push   $0x0
  pushl $110
8010718e:	6a 6e                	push   $0x6e
  jmp alltraps
80107190:	e9 df f5 ff ff       	jmp    80106774 <alltraps>

80107195 <vector111>:
.globl vector111
vector111:
  pushl $0
80107195:	6a 00                	push   $0x0
  pushl $111
80107197:	6a 6f                	push   $0x6f
  jmp alltraps
80107199:	e9 d6 f5 ff ff       	jmp    80106774 <alltraps>

8010719e <vector112>:
.globl vector112
vector112:
  pushl $0
8010719e:	6a 00                	push   $0x0
  pushl $112
801071a0:	6a 70                	push   $0x70
  jmp alltraps
801071a2:	e9 cd f5 ff ff       	jmp    80106774 <alltraps>

801071a7 <vector113>:
.globl vector113
vector113:
  pushl $0
801071a7:	6a 00                	push   $0x0
  pushl $113
801071a9:	6a 71                	push   $0x71
  jmp alltraps
801071ab:	e9 c4 f5 ff ff       	jmp    80106774 <alltraps>

801071b0 <vector114>:
.globl vector114
vector114:
  pushl $0
801071b0:	6a 00                	push   $0x0
  pushl $114
801071b2:	6a 72                	push   $0x72
  jmp alltraps
801071b4:	e9 bb f5 ff ff       	jmp    80106774 <alltraps>

801071b9 <vector115>:
.globl vector115
vector115:
  pushl $0
801071b9:	6a 00                	push   $0x0
  pushl $115
801071bb:	6a 73                	push   $0x73
  jmp alltraps
801071bd:	e9 b2 f5 ff ff       	jmp    80106774 <alltraps>

801071c2 <vector116>:
.globl vector116
vector116:
  pushl $0
801071c2:	6a 00                	push   $0x0
  pushl $116
801071c4:	6a 74                	push   $0x74
  jmp alltraps
801071c6:	e9 a9 f5 ff ff       	jmp    80106774 <alltraps>

801071cb <vector117>:
.globl vector117
vector117:
  pushl $0
801071cb:	6a 00                	push   $0x0
  pushl $117
801071cd:	6a 75                	push   $0x75
  jmp alltraps
801071cf:	e9 a0 f5 ff ff       	jmp    80106774 <alltraps>

801071d4 <vector118>:
.globl vector118
vector118:
  pushl $0
801071d4:	6a 00                	push   $0x0
  pushl $118
801071d6:	6a 76                	push   $0x76
  jmp alltraps
801071d8:	e9 97 f5 ff ff       	jmp    80106774 <alltraps>

801071dd <vector119>:
.globl vector119
vector119:
  pushl $0
801071dd:	6a 00                	push   $0x0
  pushl $119
801071df:	6a 77                	push   $0x77
  jmp alltraps
801071e1:	e9 8e f5 ff ff       	jmp    80106774 <alltraps>

801071e6 <vector120>:
.globl vector120
vector120:
  pushl $0
801071e6:	6a 00                	push   $0x0
  pushl $120
801071e8:	6a 78                	push   $0x78
  jmp alltraps
801071ea:	e9 85 f5 ff ff       	jmp    80106774 <alltraps>

801071ef <vector121>:
.globl vector121
vector121:
  pushl $0
801071ef:	6a 00                	push   $0x0
  pushl $121
801071f1:	6a 79                	push   $0x79
  jmp alltraps
801071f3:	e9 7c f5 ff ff       	jmp    80106774 <alltraps>

801071f8 <vector122>:
.globl vector122
vector122:
  pushl $0
801071f8:	6a 00                	push   $0x0
  pushl $122
801071fa:	6a 7a                	push   $0x7a
  jmp alltraps
801071fc:	e9 73 f5 ff ff       	jmp    80106774 <alltraps>

80107201 <vector123>:
.globl vector123
vector123:
  pushl $0
80107201:	6a 00                	push   $0x0
  pushl $123
80107203:	6a 7b                	push   $0x7b
  jmp alltraps
80107205:	e9 6a f5 ff ff       	jmp    80106774 <alltraps>

8010720a <vector124>:
.globl vector124
vector124:
  pushl $0
8010720a:	6a 00                	push   $0x0
  pushl $124
8010720c:	6a 7c                	push   $0x7c
  jmp alltraps
8010720e:	e9 61 f5 ff ff       	jmp    80106774 <alltraps>

80107213 <vector125>:
.globl vector125
vector125:
  pushl $0
80107213:	6a 00                	push   $0x0
  pushl $125
80107215:	6a 7d                	push   $0x7d
  jmp alltraps
80107217:	e9 58 f5 ff ff       	jmp    80106774 <alltraps>

8010721c <vector126>:
.globl vector126
vector126:
  pushl $0
8010721c:	6a 00                	push   $0x0
  pushl $126
8010721e:	6a 7e                	push   $0x7e
  jmp alltraps
80107220:	e9 4f f5 ff ff       	jmp    80106774 <alltraps>

80107225 <vector127>:
.globl vector127
vector127:
  pushl $0
80107225:	6a 00                	push   $0x0
  pushl $127
80107227:	6a 7f                	push   $0x7f
  jmp alltraps
80107229:	e9 46 f5 ff ff       	jmp    80106774 <alltraps>

8010722e <vector128>:
.globl vector128
vector128:
  pushl $0
8010722e:	6a 00                	push   $0x0
  pushl $128
80107230:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107235:	e9 3a f5 ff ff       	jmp    80106774 <alltraps>

8010723a <vector129>:
.globl vector129
vector129:
  pushl $0
8010723a:	6a 00                	push   $0x0
  pushl $129
8010723c:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107241:	e9 2e f5 ff ff       	jmp    80106774 <alltraps>

80107246 <vector130>:
.globl vector130
vector130:
  pushl $0
80107246:	6a 00                	push   $0x0
  pushl $130
80107248:	68 82 00 00 00       	push   $0x82
  jmp alltraps
8010724d:	e9 22 f5 ff ff       	jmp    80106774 <alltraps>

80107252 <vector131>:
.globl vector131
vector131:
  pushl $0
80107252:	6a 00                	push   $0x0
  pushl $131
80107254:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107259:	e9 16 f5 ff ff       	jmp    80106774 <alltraps>

8010725e <vector132>:
.globl vector132
vector132:
  pushl $0
8010725e:	6a 00                	push   $0x0
  pushl $132
80107260:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107265:	e9 0a f5 ff ff       	jmp    80106774 <alltraps>

8010726a <vector133>:
.globl vector133
vector133:
  pushl $0
8010726a:	6a 00                	push   $0x0
  pushl $133
8010726c:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107271:	e9 fe f4 ff ff       	jmp    80106774 <alltraps>

80107276 <vector134>:
.globl vector134
vector134:
  pushl $0
80107276:	6a 00                	push   $0x0
  pushl $134
80107278:	68 86 00 00 00       	push   $0x86
  jmp alltraps
8010727d:	e9 f2 f4 ff ff       	jmp    80106774 <alltraps>

80107282 <vector135>:
.globl vector135
vector135:
  pushl $0
80107282:	6a 00                	push   $0x0
  pushl $135
80107284:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107289:	e9 e6 f4 ff ff       	jmp    80106774 <alltraps>

8010728e <vector136>:
.globl vector136
vector136:
  pushl $0
8010728e:	6a 00                	push   $0x0
  pushl $136
80107290:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107295:	e9 da f4 ff ff       	jmp    80106774 <alltraps>

8010729a <vector137>:
.globl vector137
vector137:
  pushl $0
8010729a:	6a 00                	push   $0x0
  pushl $137
8010729c:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801072a1:	e9 ce f4 ff ff       	jmp    80106774 <alltraps>

801072a6 <vector138>:
.globl vector138
vector138:
  pushl $0
801072a6:	6a 00                	push   $0x0
  pushl $138
801072a8:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801072ad:	e9 c2 f4 ff ff       	jmp    80106774 <alltraps>

801072b2 <vector139>:
.globl vector139
vector139:
  pushl $0
801072b2:	6a 00                	push   $0x0
  pushl $139
801072b4:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801072b9:	e9 b6 f4 ff ff       	jmp    80106774 <alltraps>

801072be <vector140>:
.globl vector140
vector140:
  pushl $0
801072be:	6a 00                	push   $0x0
  pushl $140
801072c0:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801072c5:	e9 aa f4 ff ff       	jmp    80106774 <alltraps>

801072ca <vector141>:
.globl vector141
vector141:
  pushl $0
801072ca:	6a 00                	push   $0x0
  pushl $141
801072cc:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801072d1:	e9 9e f4 ff ff       	jmp    80106774 <alltraps>

801072d6 <vector142>:
.globl vector142
vector142:
  pushl $0
801072d6:	6a 00                	push   $0x0
  pushl $142
801072d8:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801072dd:	e9 92 f4 ff ff       	jmp    80106774 <alltraps>

801072e2 <vector143>:
.globl vector143
vector143:
  pushl $0
801072e2:	6a 00                	push   $0x0
  pushl $143
801072e4:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801072e9:	e9 86 f4 ff ff       	jmp    80106774 <alltraps>

801072ee <vector144>:
.globl vector144
vector144:
  pushl $0
801072ee:	6a 00                	push   $0x0
  pushl $144
801072f0:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801072f5:	e9 7a f4 ff ff       	jmp    80106774 <alltraps>

801072fa <vector145>:
.globl vector145
vector145:
  pushl $0
801072fa:	6a 00                	push   $0x0
  pushl $145
801072fc:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107301:	e9 6e f4 ff ff       	jmp    80106774 <alltraps>

80107306 <vector146>:
.globl vector146
vector146:
  pushl $0
80107306:	6a 00                	push   $0x0
  pushl $146
80107308:	68 92 00 00 00       	push   $0x92
  jmp alltraps
8010730d:	e9 62 f4 ff ff       	jmp    80106774 <alltraps>

80107312 <vector147>:
.globl vector147
vector147:
  pushl $0
80107312:	6a 00                	push   $0x0
  pushl $147
80107314:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107319:	e9 56 f4 ff ff       	jmp    80106774 <alltraps>

8010731e <vector148>:
.globl vector148
vector148:
  pushl $0
8010731e:	6a 00                	push   $0x0
  pushl $148
80107320:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107325:	e9 4a f4 ff ff       	jmp    80106774 <alltraps>

8010732a <vector149>:
.globl vector149
vector149:
  pushl $0
8010732a:	6a 00                	push   $0x0
  pushl $149
8010732c:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107331:	e9 3e f4 ff ff       	jmp    80106774 <alltraps>

80107336 <vector150>:
.globl vector150
vector150:
  pushl $0
80107336:	6a 00                	push   $0x0
  pushl $150
80107338:	68 96 00 00 00       	push   $0x96
  jmp alltraps
8010733d:	e9 32 f4 ff ff       	jmp    80106774 <alltraps>

80107342 <vector151>:
.globl vector151
vector151:
  pushl $0
80107342:	6a 00                	push   $0x0
  pushl $151
80107344:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107349:	e9 26 f4 ff ff       	jmp    80106774 <alltraps>

8010734e <vector152>:
.globl vector152
vector152:
  pushl $0
8010734e:	6a 00                	push   $0x0
  pushl $152
80107350:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107355:	e9 1a f4 ff ff       	jmp    80106774 <alltraps>

8010735a <vector153>:
.globl vector153
vector153:
  pushl $0
8010735a:	6a 00                	push   $0x0
  pushl $153
8010735c:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107361:	e9 0e f4 ff ff       	jmp    80106774 <alltraps>

80107366 <vector154>:
.globl vector154
vector154:
  pushl $0
80107366:	6a 00                	push   $0x0
  pushl $154
80107368:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
8010736d:	e9 02 f4 ff ff       	jmp    80106774 <alltraps>

80107372 <vector155>:
.globl vector155
vector155:
  pushl $0
80107372:	6a 00                	push   $0x0
  pushl $155
80107374:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107379:	e9 f6 f3 ff ff       	jmp    80106774 <alltraps>

8010737e <vector156>:
.globl vector156
vector156:
  pushl $0
8010737e:	6a 00                	push   $0x0
  pushl $156
80107380:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107385:	e9 ea f3 ff ff       	jmp    80106774 <alltraps>

8010738a <vector157>:
.globl vector157
vector157:
  pushl $0
8010738a:	6a 00                	push   $0x0
  pushl $157
8010738c:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107391:	e9 de f3 ff ff       	jmp    80106774 <alltraps>

80107396 <vector158>:
.globl vector158
vector158:
  pushl $0
80107396:	6a 00                	push   $0x0
  pushl $158
80107398:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010739d:	e9 d2 f3 ff ff       	jmp    80106774 <alltraps>

801073a2 <vector159>:
.globl vector159
vector159:
  pushl $0
801073a2:	6a 00                	push   $0x0
  pushl $159
801073a4:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801073a9:	e9 c6 f3 ff ff       	jmp    80106774 <alltraps>

801073ae <vector160>:
.globl vector160
vector160:
  pushl $0
801073ae:	6a 00                	push   $0x0
  pushl $160
801073b0:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801073b5:	e9 ba f3 ff ff       	jmp    80106774 <alltraps>

801073ba <vector161>:
.globl vector161
vector161:
  pushl $0
801073ba:	6a 00                	push   $0x0
  pushl $161
801073bc:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801073c1:	e9 ae f3 ff ff       	jmp    80106774 <alltraps>

801073c6 <vector162>:
.globl vector162
vector162:
  pushl $0
801073c6:	6a 00                	push   $0x0
  pushl $162
801073c8:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801073cd:	e9 a2 f3 ff ff       	jmp    80106774 <alltraps>

801073d2 <vector163>:
.globl vector163
vector163:
  pushl $0
801073d2:	6a 00                	push   $0x0
  pushl $163
801073d4:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801073d9:	e9 96 f3 ff ff       	jmp    80106774 <alltraps>

801073de <vector164>:
.globl vector164
vector164:
  pushl $0
801073de:	6a 00                	push   $0x0
  pushl $164
801073e0:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801073e5:	e9 8a f3 ff ff       	jmp    80106774 <alltraps>

801073ea <vector165>:
.globl vector165
vector165:
  pushl $0
801073ea:	6a 00                	push   $0x0
  pushl $165
801073ec:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801073f1:	e9 7e f3 ff ff       	jmp    80106774 <alltraps>

801073f6 <vector166>:
.globl vector166
vector166:
  pushl $0
801073f6:	6a 00                	push   $0x0
  pushl $166
801073f8:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801073fd:	e9 72 f3 ff ff       	jmp    80106774 <alltraps>

80107402 <vector167>:
.globl vector167
vector167:
  pushl $0
80107402:	6a 00                	push   $0x0
  pushl $167
80107404:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107409:	e9 66 f3 ff ff       	jmp    80106774 <alltraps>

8010740e <vector168>:
.globl vector168
vector168:
  pushl $0
8010740e:	6a 00                	push   $0x0
  pushl $168
80107410:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107415:	e9 5a f3 ff ff       	jmp    80106774 <alltraps>

8010741a <vector169>:
.globl vector169
vector169:
  pushl $0
8010741a:	6a 00                	push   $0x0
  pushl $169
8010741c:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107421:	e9 4e f3 ff ff       	jmp    80106774 <alltraps>

80107426 <vector170>:
.globl vector170
vector170:
  pushl $0
80107426:	6a 00                	push   $0x0
  pushl $170
80107428:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
8010742d:	e9 42 f3 ff ff       	jmp    80106774 <alltraps>

80107432 <vector171>:
.globl vector171
vector171:
  pushl $0
80107432:	6a 00                	push   $0x0
  pushl $171
80107434:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107439:	e9 36 f3 ff ff       	jmp    80106774 <alltraps>

8010743e <vector172>:
.globl vector172
vector172:
  pushl $0
8010743e:	6a 00                	push   $0x0
  pushl $172
80107440:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107445:	e9 2a f3 ff ff       	jmp    80106774 <alltraps>

8010744a <vector173>:
.globl vector173
vector173:
  pushl $0
8010744a:	6a 00                	push   $0x0
  pushl $173
8010744c:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107451:	e9 1e f3 ff ff       	jmp    80106774 <alltraps>

80107456 <vector174>:
.globl vector174
vector174:
  pushl $0
80107456:	6a 00                	push   $0x0
  pushl $174
80107458:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
8010745d:	e9 12 f3 ff ff       	jmp    80106774 <alltraps>

80107462 <vector175>:
.globl vector175
vector175:
  pushl $0
80107462:	6a 00                	push   $0x0
  pushl $175
80107464:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107469:	e9 06 f3 ff ff       	jmp    80106774 <alltraps>

8010746e <vector176>:
.globl vector176
vector176:
  pushl $0
8010746e:	6a 00                	push   $0x0
  pushl $176
80107470:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107475:	e9 fa f2 ff ff       	jmp    80106774 <alltraps>

8010747a <vector177>:
.globl vector177
vector177:
  pushl $0
8010747a:	6a 00                	push   $0x0
  pushl $177
8010747c:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107481:	e9 ee f2 ff ff       	jmp    80106774 <alltraps>

80107486 <vector178>:
.globl vector178
vector178:
  pushl $0
80107486:	6a 00                	push   $0x0
  pushl $178
80107488:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
8010748d:	e9 e2 f2 ff ff       	jmp    80106774 <alltraps>

80107492 <vector179>:
.globl vector179
vector179:
  pushl $0
80107492:	6a 00                	push   $0x0
  pushl $179
80107494:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107499:	e9 d6 f2 ff ff       	jmp    80106774 <alltraps>

8010749e <vector180>:
.globl vector180
vector180:
  pushl $0
8010749e:	6a 00                	push   $0x0
  pushl $180
801074a0:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801074a5:	e9 ca f2 ff ff       	jmp    80106774 <alltraps>

801074aa <vector181>:
.globl vector181
vector181:
  pushl $0
801074aa:	6a 00                	push   $0x0
  pushl $181
801074ac:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801074b1:	e9 be f2 ff ff       	jmp    80106774 <alltraps>

801074b6 <vector182>:
.globl vector182
vector182:
  pushl $0
801074b6:	6a 00                	push   $0x0
  pushl $182
801074b8:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801074bd:	e9 b2 f2 ff ff       	jmp    80106774 <alltraps>

801074c2 <vector183>:
.globl vector183
vector183:
  pushl $0
801074c2:	6a 00                	push   $0x0
  pushl $183
801074c4:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801074c9:	e9 a6 f2 ff ff       	jmp    80106774 <alltraps>

801074ce <vector184>:
.globl vector184
vector184:
  pushl $0
801074ce:	6a 00                	push   $0x0
  pushl $184
801074d0:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801074d5:	e9 9a f2 ff ff       	jmp    80106774 <alltraps>

801074da <vector185>:
.globl vector185
vector185:
  pushl $0
801074da:	6a 00                	push   $0x0
  pushl $185
801074dc:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801074e1:	e9 8e f2 ff ff       	jmp    80106774 <alltraps>

801074e6 <vector186>:
.globl vector186
vector186:
  pushl $0
801074e6:	6a 00                	push   $0x0
  pushl $186
801074e8:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801074ed:	e9 82 f2 ff ff       	jmp    80106774 <alltraps>

801074f2 <vector187>:
.globl vector187
vector187:
  pushl $0
801074f2:	6a 00                	push   $0x0
  pushl $187
801074f4:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801074f9:	e9 76 f2 ff ff       	jmp    80106774 <alltraps>

801074fe <vector188>:
.globl vector188
vector188:
  pushl $0
801074fe:	6a 00                	push   $0x0
  pushl $188
80107500:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107505:	e9 6a f2 ff ff       	jmp    80106774 <alltraps>

8010750a <vector189>:
.globl vector189
vector189:
  pushl $0
8010750a:	6a 00                	push   $0x0
  pushl $189
8010750c:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107511:	e9 5e f2 ff ff       	jmp    80106774 <alltraps>

80107516 <vector190>:
.globl vector190
vector190:
  pushl $0
80107516:	6a 00                	push   $0x0
  pushl $190
80107518:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
8010751d:	e9 52 f2 ff ff       	jmp    80106774 <alltraps>

80107522 <vector191>:
.globl vector191
vector191:
  pushl $0
80107522:	6a 00                	push   $0x0
  pushl $191
80107524:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107529:	e9 46 f2 ff ff       	jmp    80106774 <alltraps>

8010752e <vector192>:
.globl vector192
vector192:
  pushl $0
8010752e:	6a 00                	push   $0x0
  pushl $192
80107530:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107535:	e9 3a f2 ff ff       	jmp    80106774 <alltraps>

8010753a <vector193>:
.globl vector193
vector193:
  pushl $0
8010753a:	6a 00                	push   $0x0
  pushl $193
8010753c:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107541:	e9 2e f2 ff ff       	jmp    80106774 <alltraps>

80107546 <vector194>:
.globl vector194
vector194:
  pushl $0
80107546:	6a 00                	push   $0x0
  pushl $194
80107548:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
8010754d:	e9 22 f2 ff ff       	jmp    80106774 <alltraps>

80107552 <vector195>:
.globl vector195
vector195:
  pushl $0
80107552:	6a 00                	push   $0x0
  pushl $195
80107554:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107559:	e9 16 f2 ff ff       	jmp    80106774 <alltraps>

8010755e <vector196>:
.globl vector196
vector196:
  pushl $0
8010755e:	6a 00                	push   $0x0
  pushl $196
80107560:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107565:	e9 0a f2 ff ff       	jmp    80106774 <alltraps>

8010756a <vector197>:
.globl vector197
vector197:
  pushl $0
8010756a:	6a 00                	push   $0x0
  pushl $197
8010756c:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107571:	e9 fe f1 ff ff       	jmp    80106774 <alltraps>

80107576 <vector198>:
.globl vector198
vector198:
  pushl $0
80107576:	6a 00                	push   $0x0
  pushl $198
80107578:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010757d:	e9 f2 f1 ff ff       	jmp    80106774 <alltraps>

80107582 <vector199>:
.globl vector199
vector199:
  pushl $0
80107582:	6a 00                	push   $0x0
  pushl $199
80107584:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107589:	e9 e6 f1 ff ff       	jmp    80106774 <alltraps>

8010758e <vector200>:
.globl vector200
vector200:
  pushl $0
8010758e:	6a 00                	push   $0x0
  pushl $200
80107590:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107595:	e9 da f1 ff ff       	jmp    80106774 <alltraps>

8010759a <vector201>:
.globl vector201
vector201:
  pushl $0
8010759a:	6a 00                	push   $0x0
  pushl $201
8010759c:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801075a1:	e9 ce f1 ff ff       	jmp    80106774 <alltraps>

801075a6 <vector202>:
.globl vector202
vector202:
  pushl $0
801075a6:	6a 00                	push   $0x0
  pushl $202
801075a8:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801075ad:	e9 c2 f1 ff ff       	jmp    80106774 <alltraps>

801075b2 <vector203>:
.globl vector203
vector203:
  pushl $0
801075b2:	6a 00                	push   $0x0
  pushl $203
801075b4:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801075b9:	e9 b6 f1 ff ff       	jmp    80106774 <alltraps>

801075be <vector204>:
.globl vector204
vector204:
  pushl $0
801075be:	6a 00                	push   $0x0
  pushl $204
801075c0:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801075c5:	e9 aa f1 ff ff       	jmp    80106774 <alltraps>

801075ca <vector205>:
.globl vector205
vector205:
  pushl $0
801075ca:	6a 00                	push   $0x0
  pushl $205
801075cc:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801075d1:	e9 9e f1 ff ff       	jmp    80106774 <alltraps>

801075d6 <vector206>:
.globl vector206
vector206:
  pushl $0
801075d6:	6a 00                	push   $0x0
  pushl $206
801075d8:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801075dd:	e9 92 f1 ff ff       	jmp    80106774 <alltraps>

801075e2 <vector207>:
.globl vector207
vector207:
  pushl $0
801075e2:	6a 00                	push   $0x0
  pushl $207
801075e4:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801075e9:	e9 86 f1 ff ff       	jmp    80106774 <alltraps>

801075ee <vector208>:
.globl vector208
vector208:
  pushl $0
801075ee:	6a 00                	push   $0x0
  pushl $208
801075f0:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801075f5:	e9 7a f1 ff ff       	jmp    80106774 <alltraps>

801075fa <vector209>:
.globl vector209
vector209:
  pushl $0
801075fa:	6a 00                	push   $0x0
  pushl $209
801075fc:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107601:	e9 6e f1 ff ff       	jmp    80106774 <alltraps>

80107606 <vector210>:
.globl vector210
vector210:
  pushl $0
80107606:	6a 00                	push   $0x0
  pushl $210
80107608:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
8010760d:	e9 62 f1 ff ff       	jmp    80106774 <alltraps>

80107612 <vector211>:
.globl vector211
vector211:
  pushl $0
80107612:	6a 00                	push   $0x0
  pushl $211
80107614:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107619:	e9 56 f1 ff ff       	jmp    80106774 <alltraps>

8010761e <vector212>:
.globl vector212
vector212:
  pushl $0
8010761e:	6a 00                	push   $0x0
  pushl $212
80107620:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107625:	e9 4a f1 ff ff       	jmp    80106774 <alltraps>

8010762a <vector213>:
.globl vector213
vector213:
  pushl $0
8010762a:	6a 00                	push   $0x0
  pushl $213
8010762c:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107631:	e9 3e f1 ff ff       	jmp    80106774 <alltraps>

80107636 <vector214>:
.globl vector214
vector214:
  pushl $0
80107636:	6a 00                	push   $0x0
  pushl $214
80107638:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
8010763d:	e9 32 f1 ff ff       	jmp    80106774 <alltraps>

80107642 <vector215>:
.globl vector215
vector215:
  pushl $0
80107642:	6a 00                	push   $0x0
  pushl $215
80107644:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107649:	e9 26 f1 ff ff       	jmp    80106774 <alltraps>

8010764e <vector216>:
.globl vector216
vector216:
  pushl $0
8010764e:	6a 00                	push   $0x0
  pushl $216
80107650:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107655:	e9 1a f1 ff ff       	jmp    80106774 <alltraps>

8010765a <vector217>:
.globl vector217
vector217:
  pushl $0
8010765a:	6a 00                	push   $0x0
  pushl $217
8010765c:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107661:	e9 0e f1 ff ff       	jmp    80106774 <alltraps>

80107666 <vector218>:
.globl vector218
vector218:
  pushl $0
80107666:	6a 00                	push   $0x0
  pushl $218
80107668:	68 da 00 00 00       	push   $0xda
  jmp alltraps
8010766d:	e9 02 f1 ff ff       	jmp    80106774 <alltraps>

80107672 <vector219>:
.globl vector219
vector219:
  pushl $0
80107672:	6a 00                	push   $0x0
  pushl $219
80107674:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107679:	e9 f6 f0 ff ff       	jmp    80106774 <alltraps>

8010767e <vector220>:
.globl vector220
vector220:
  pushl $0
8010767e:	6a 00                	push   $0x0
  pushl $220
80107680:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107685:	e9 ea f0 ff ff       	jmp    80106774 <alltraps>

8010768a <vector221>:
.globl vector221
vector221:
  pushl $0
8010768a:	6a 00                	push   $0x0
  pushl $221
8010768c:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107691:	e9 de f0 ff ff       	jmp    80106774 <alltraps>

80107696 <vector222>:
.globl vector222
vector222:
  pushl $0
80107696:	6a 00                	push   $0x0
  pushl $222
80107698:	68 de 00 00 00       	push   $0xde
  jmp alltraps
8010769d:	e9 d2 f0 ff ff       	jmp    80106774 <alltraps>

801076a2 <vector223>:
.globl vector223
vector223:
  pushl $0
801076a2:	6a 00                	push   $0x0
  pushl $223
801076a4:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801076a9:	e9 c6 f0 ff ff       	jmp    80106774 <alltraps>

801076ae <vector224>:
.globl vector224
vector224:
  pushl $0
801076ae:	6a 00                	push   $0x0
  pushl $224
801076b0:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801076b5:	e9 ba f0 ff ff       	jmp    80106774 <alltraps>

801076ba <vector225>:
.globl vector225
vector225:
  pushl $0
801076ba:	6a 00                	push   $0x0
  pushl $225
801076bc:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801076c1:	e9 ae f0 ff ff       	jmp    80106774 <alltraps>

801076c6 <vector226>:
.globl vector226
vector226:
  pushl $0
801076c6:	6a 00                	push   $0x0
  pushl $226
801076c8:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801076cd:	e9 a2 f0 ff ff       	jmp    80106774 <alltraps>

801076d2 <vector227>:
.globl vector227
vector227:
  pushl $0
801076d2:	6a 00                	push   $0x0
  pushl $227
801076d4:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801076d9:	e9 96 f0 ff ff       	jmp    80106774 <alltraps>

801076de <vector228>:
.globl vector228
vector228:
  pushl $0
801076de:	6a 00                	push   $0x0
  pushl $228
801076e0:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801076e5:	e9 8a f0 ff ff       	jmp    80106774 <alltraps>

801076ea <vector229>:
.globl vector229
vector229:
  pushl $0
801076ea:	6a 00                	push   $0x0
  pushl $229
801076ec:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801076f1:	e9 7e f0 ff ff       	jmp    80106774 <alltraps>

801076f6 <vector230>:
.globl vector230
vector230:
  pushl $0
801076f6:	6a 00                	push   $0x0
  pushl $230
801076f8:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801076fd:	e9 72 f0 ff ff       	jmp    80106774 <alltraps>

80107702 <vector231>:
.globl vector231
vector231:
  pushl $0
80107702:	6a 00                	push   $0x0
  pushl $231
80107704:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107709:	e9 66 f0 ff ff       	jmp    80106774 <alltraps>

8010770e <vector232>:
.globl vector232
vector232:
  pushl $0
8010770e:	6a 00                	push   $0x0
  pushl $232
80107710:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107715:	e9 5a f0 ff ff       	jmp    80106774 <alltraps>

8010771a <vector233>:
.globl vector233
vector233:
  pushl $0
8010771a:	6a 00                	push   $0x0
  pushl $233
8010771c:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107721:	e9 4e f0 ff ff       	jmp    80106774 <alltraps>

80107726 <vector234>:
.globl vector234
vector234:
  pushl $0
80107726:	6a 00                	push   $0x0
  pushl $234
80107728:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
8010772d:	e9 42 f0 ff ff       	jmp    80106774 <alltraps>

80107732 <vector235>:
.globl vector235
vector235:
  pushl $0
80107732:	6a 00                	push   $0x0
  pushl $235
80107734:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107739:	e9 36 f0 ff ff       	jmp    80106774 <alltraps>

8010773e <vector236>:
.globl vector236
vector236:
  pushl $0
8010773e:	6a 00                	push   $0x0
  pushl $236
80107740:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107745:	e9 2a f0 ff ff       	jmp    80106774 <alltraps>

8010774a <vector237>:
.globl vector237
vector237:
  pushl $0
8010774a:	6a 00                	push   $0x0
  pushl $237
8010774c:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107751:	e9 1e f0 ff ff       	jmp    80106774 <alltraps>

80107756 <vector238>:
.globl vector238
vector238:
  pushl $0
80107756:	6a 00                	push   $0x0
  pushl $238
80107758:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
8010775d:	e9 12 f0 ff ff       	jmp    80106774 <alltraps>

80107762 <vector239>:
.globl vector239
vector239:
  pushl $0
80107762:	6a 00                	push   $0x0
  pushl $239
80107764:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107769:	e9 06 f0 ff ff       	jmp    80106774 <alltraps>

8010776e <vector240>:
.globl vector240
vector240:
  pushl $0
8010776e:	6a 00                	push   $0x0
  pushl $240
80107770:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107775:	e9 fa ef ff ff       	jmp    80106774 <alltraps>

8010777a <vector241>:
.globl vector241
vector241:
  pushl $0
8010777a:	6a 00                	push   $0x0
  pushl $241
8010777c:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107781:	e9 ee ef ff ff       	jmp    80106774 <alltraps>

80107786 <vector242>:
.globl vector242
vector242:
  pushl $0
80107786:	6a 00                	push   $0x0
  pushl $242
80107788:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
8010778d:	e9 e2 ef ff ff       	jmp    80106774 <alltraps>

80107792 <vector243>:
.globl vector243
vector243:
  pushl $0
80107792:	6a 00                	push   $0x0
  pushl $243
80107794:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107799:	e9 d6 ef ff ff       	jmp    80106774 <alltraps>

8010779e <vector244>:
.globl vector244
vector244:
  pushl $0
8010779e:	6a 00                	push   $0x0
  pushl $244
801077a0:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801077a5:	e9 ca ef ff ff       	jmp    80106774 <alltraps>

801077aa <vector245>:
.globl vector245
vector245:
  pushl $0
801077aa:	6a 00                	push   $0x0
  pushl $245
801077ac:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801077b1:	e9 be ef ff ff       	jmp    80106774 <alltraps>

801077b6 <vector246>:
.globl vector246
vector246:
  pushl $0
801077b6:	6a 00                	push   $0x0
  pushl $246
801077b8:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801077bd:	e9 b2 ef ff ff       	jmp    80106774 <alltraps>

801077c2 <vector247>:
.globl vector247
vector247:
  pushl $0
801077c2:	6a 00                	push   $0x0
  pushl $247
801077c4:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801077c9:	e9 a6 ef ff ff       	jmp    80106774 <alltraps>

801077ce <vector248>:
.globl vector248
vector248:
  pushl $0
801077ce:	6a 00                	push   $0x0
  pushl $248
801077d0:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801077d5:	e9 9a ef ff ff       	jmp    80106774 <alltraps>

801077da <vector249>:
.globl vector249
vector249:
  pushl $0
801077da:	6a 00                	push   $0x0
  pushl $249
801077dc:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801077e1:	e9 8e ef ff ff       	jmp    80106774 <alltraps>

801077e6 <vector250>:
.globl vector250
vector250:
  pushl $0
801077e6:	6a 00                	push   $0x0
  pushl $250
801077e8:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801077ed:	e9 82 ef ff ff       	jmp    80106774 <alltraps>

801077f2 <vector251>:
.globl vector251
vector251:
  pushl $0
801077f2:	6a 00                	push   $0x0
  pushl $251
801077f4:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801077f9:	e9 76 ef ff ff       	jmp    80106774 <alltraps>

801077fe <vector252>:
.globl vector252
vector252:
  pushl $0
801077fe:	6a 00                	push   $0x0
  pushl $252
80107800:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107805:	e9 6a ef ff ff       	jmp    80106774 <alltraps>

8010780a <vector253>:
.globl vector253
vector253:
  pushl $0
8010780a:	6a 00                	push   $0x0
  pushl $253
8010780c:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107811:	e9 5e ef ff ff       	jmp    80106774 <alltraps>

80107816 <vector254>:
.globl vector254
vector254:
  pushl $0
80107816:	6a 00                	push   $0x0
  pushl $254
80107818:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
8010781d:	e9 52 ef ff ff       	jmp    80106774 <alltraps>

80107822 <vector255>:
.globl vector255
vector255:
  pushl $0
80107822:	6a 00                	push   $0x0
  pushl $255
80107824:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107829:	e9 46 ef ff ff       	jmp    80106774 <alltraps>
	...

80107830 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107830:	55                   	push   %ebp
80107831:	89 e5                	mov    %esp,%ebp
80107833:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107836:	8b 45 0c             	mov    0xc(%ebp),%eax
80107839:	48                   	dec    %eax
8010783a:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010783e:	8b 45 08             	mov    0x8(%ebp),%eax
80107841:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107845:	8b 45 08             	mov    0x8(%ebp),%eax
80107848:	c1 e8 10             	shr    $0x10,%eax
8010784b:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
8010784f:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107852:	0f 01 10             	lgdtl  (%eax)
}
80107855:	c9                   	leave  
80107856:	c3                   	ret    

80107857 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80107857:	55                   	push   %ebp
80107858:	89 e5                	mov    %esp,%ebp
8010785a:	83 ec 04             	sub    $0x4,%esp
8010785d:	8b 45 08             	mov    0x8(%ebp),%eax
80107860:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107864:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107867:	0f 00 d8             	ltr    %ax
}
8010786a:	c9                   	leave  
8010786b:	c3                   	ret    

8010786c <lcr3>:
  return val;
}

static inline void
lcr3(uint val)
{
8010786c:	55                   	push   %ebp
8010786d:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010786f:	8b 45 08             	mov    0x8(%ebp),%eax
80107872:	0f 22 d8             	mov    %eax,%cr3
}
80107875:	5d                   	pop    %ebp
80107876:	c3                   	ret    

80107877 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107877:	55                   	push   %ebp
80107878:	89 e5                	mov    %esp,%ebp
8010787a:	83 ec 28             	sub    $0x28,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
8010787d:	e8 54 c9 ff ff       	call   801041d6 <cpuid>
80107882:	89 c2                	mov    %eax,%edx
80107884:	89 d0                	mov    %edx,%eax
80107886:	c1 e0 02             	shl    $0x2,%eax
80107889:	01 d0                	add    %edx,%eax
8010788b:	01 c0                	add    %eax,%eax
8010788d:	01 d0                	add    %edx,%eax
8010788f:	c1 e0 04             	shl    $0x4,%eax
80107892:	05 a0 3a 11 80       	add    $0x80113aa0,%eax
80107897:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
8010789a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010789d:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801078a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078a6:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801078ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078af:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801078b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078b6:	8a 50 7d             	mov    0x7d(%eax),%dl
801078b9:	83 e2 f0             	and    $0xfffffff0,%edx
801078bc:	83 ca 0a             	or     $0xa,%edx
801078bf:	88 50 7d             	mov    %dl,0x7d(%eax)
801078c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078c5:	8a 50 7d             	mov    0x7d(%eax),%dl
801078c8:	83 ca 10             	or     $0x10,%edx
801078cb:	88 50 7d             	mov    %dl,0x7d(%eax)
801078ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078d1:	8a 50 7d             	mov    0x7d(%eax),%dl
801078d4:	83 e2 9f             	and    $0xffffff9f,%edx
801078d7:	88 50 7d             	mov    %dl,0x7d(%eax)
801078da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078dd:	8a 50 7d             	mov    0x7d(%eax),%dl
801078e0:	83 ca 80             	or     $0xffffff80,%edx
801078e3:	88 50 7d             	mov    %dl,0x7d(%eax)
801078e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078e9:	8a 50 7e             	mov    0x7e(%eax),%dl
801078ec:	83 ca 0f             	or     $0xf,%edx
801078ef:	88 50 7e             	mov    %dl,0x7e(%eax)
801078f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078f5:	8a 50 7e             	mov    0x7e(%eax),%dl
801078f8:	83 e2 ef             	and    $0xffffffef,%edx
801078fb:	88 50 7e             	mov    %dl,0x7e(%eax)
801078fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107901:	8a 50 7e             	mov    0x7e(%eax),%dl
80107904:	83 e2 df             	and    $0xffffffdf,%edx
80107907:	88 50 7e             	mov    %dl,0x7e(%eax)
8010790a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010790d:	8a 50 7e             	mov    0x7e(%eax),%dl
80107910:	83 ca 40             	or     $0x40,%edx
80107913:	88 50 7e             	mov    %dl,0x7e(%eax)
80107916:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107919:	8a 50 7e             	mov    0x7e(%eax),%dl
8010791c:	83 ca 80             	or     $0xffffff80,%edx
8010791f:	88 50 7e             	mov    %dl,0x7e(%eax)
80107922:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107925:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107929:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010792c:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107933:	ff ff 
80107935:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107938:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
8010793f:	00 00 
80107941:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107944:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
8010794b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010794e:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80107954:	83 e2 f0             	and    $0xfffffff0,%edx
80107957:	83 ca 02             	or     $0x2,%edx
8010795a:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107960:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107963:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80107969:	83 ca 10             	or     $0x10,%edx
8010796c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107972:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107975:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
8010797b:	83 e2 9f             	and    $0xffffff9f,%edx
8010797e:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107984:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107987:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
8010798d:	83 ca 80             	or     $0xffffff80,%edx
80107990:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107996:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107999:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
8010799f:	83 ca 0f             	or     $0xf,%edx
801079a2:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801079a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ab:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
801079b1:	83 e2 ef             	and    $0xffffffef,%edx
801079b4:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801079ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079bd:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
801079c3:	83 e2 df             	and    $0xffffffdf,%edx
801079c6:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801079cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079cf:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
801079d5:	83 ca 40             	or     $0x40,%edx
801079d8:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801079de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079e1:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
801079e7:	83 ca 80             	or     $0xffffff80,%edx
801079ea:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801079f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079f3:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801079fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079fd:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107a04:	ff ff 
80107a06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a09:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107a10:	00 00 
80107a12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a15:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107a1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a1f:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80107a25:	83 e2 f0             	and    $0xfffffff0,%edx
80107a28:	83 ca 0a             	or     $0xa,%edx
80107a2b:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107a31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a34:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80107a3a:	83 ca 10             	or     $0x10,%edx
80107a3d:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a46:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80107a4c:	83 ca 60             	or     $0x60,%edx
80107a4f:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107a55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a58:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80107a5e:	83 ca 80             	or     $0xffffff80,%edx
80107a61:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107a67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a6a:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80107a70:	83 ca 0f             	or     $0xf,%edx
80107a73:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107a79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a7c:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80107a82:	83 e2 ef             	and    $0xffffffef,%edx
80107a85:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107a8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a8e:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80107a94:	83 e2 df             	and    $0xffffffdf,%edx
80107a97:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107a9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aa0:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80107aa6:	83 ca 40             	or     $0x40,%edx
80107aa9:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ab2:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80107ab8:	83 ca 80             	or     $0xffffff80,%edx
80107abb:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107ac1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ac4:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107acb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ace:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107ad5:	ff ff 
80107ad7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ada:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107ae1:	00 00 
80107ae3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae6:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107aed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107af0:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
80107af6:	83 e2 f0             	and    $0xfffffff0,%edx
80107af9:	83 ca 02             	or     $0x2,%edx
80107afc:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107b02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b05:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
80107b0b:	83 ca 10             	or     $0x10,%edx
80107b0e:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107b14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b17:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
80107b1d:	83 ca 60             	or     $0x60,%edx
80107b20:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107b26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b29:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
80107b2f:	83 ca 80             	or     $0xffffff80,%edx
80107b32:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107b38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b3b:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80107b41:	83 ca 0f             	or     $0xf,%edx
80107b44:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b4d:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80107b53:	83 e2 ef             	and    $0xffffffef,%edx
80107b56:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b5f:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80107b65:	83 e2 df             	and    $0xffffffdf,%edx
80107b68:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b71:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80107b77:	83 ca 40             	or     $0x40,%edx
80107b7a:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b83:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80107b89:	83 ca 80             	or     $0xffffff80,%edx
80107b8c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b95:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107b9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b9f:	83 c0 70             	add    $0x70,%eax
80107ba2:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
80107ba9:	00 
80107baa:	89 04 24             	mov    %eax,(%esp)
80107bad:	e8 7e fc ff ff       	call   80107830 <lgdt>
}
80107bb2:	c9                   	leave  
80107bb3:	c3                   	ret    

80107bb4 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107bb4:	55                   	push   %ebp
80107bb5:	89 e5                	mov    %esp,%ebp
80107bb7:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107bba:	8b 45 0c             	mov    0xc(%ebp),%eax
80107bbd:	c1 e8 16             	shr    $0x16,%eax
80107bc0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107bc7:	8b 45 08             	mov    0x8(%ebp),%eax
80107bca:	01 d0                	add    %edx,%eax
80107bcc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107bcf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107bd2:	8b 00                	mov    (%eax),%eax
80107bd4:	83 e0 01             	and    $0x1,%eax
80107bd7:	85 c0                	test   %eax,%eax
80107bd9:	74 14                	je     80107bef <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107bdb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107bde:	8b 00                	mov    (%eax),%eax
80107be0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107be5:	05 00 00 00 80       	add    $0x80000000,%eax
80107bea:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107bed:	eb 48                	jmp    80107c37 <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107bef:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107bf3:	74 0e                	je     80107c03 <walkpgdir+0x4f>
80107bf5:	e8 e5 b0 ff ff       	call   80102cdf <kalloc>
80107bfa:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107bfd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107c01:	75 07                	jne    80107c0a <walkpgdir+0x56>
      return 0;
80107c03:	b8 00 00 00 00       	mov    $0x0,%eax
80107c08:	eb 44                	jmp    80107c4e <walkpgdir+0x9a>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107c0a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107c11:	00 
80107c12:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107c19:	00 
80107c1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c1d:	89 04 24             	mov    %eax,(%esp)
80107c20:	e8 f9 d4 ff ff       	call   8010511e <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107c25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c28:	05 00 00 00 80       	add    $0x80000000,%eax
80107c2d:	83 c8 07             	or     $0x7,%eax
80107c30:	89 c2                	mov    %eax,%edx
80107c32:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c35:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107c37:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c3a:	c1 e8 0c             	shr    $0xc,%eax
80107c3d:	25 ff 03 00 00       	and    $0x3ff,%eax
80107c42:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107c49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c4c:	01 d0                	add    %edx,%eax
}
80107c4e:	c9                   	leave  
80107c4f:	c3                   	ret    

80107c50 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107c50:	55                   	push   %ebp
80107c51:	89 e5                	mov    %esp,%ebp
80107c53:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107c56:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c59:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c5e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107c61:	8b 55 0c             	mov    0xc(%ebp),%edx
80107c64:	8b 45 10             	mov    0x10(%ebp),%eax
80107c67:	01 d0                	add    %edx,%eax
80107c69:	48                   	dec    %eax
80107c6a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c6f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107c72:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80107c79:	00 
80107c7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c7d:	89 44 24 04          	mov    %eax,0x4(%esp)
80107c81:	8b 45 08             	mov    0x8(%ebp),%eax
80107c84:	89 04 24             	mov    %eax,(%esp)
80107c87:	e8 28 ff ff ff       	call   80107bb4 <walkpgdir>
80107c8c:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107c8f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107c93:	75 07                	jne    80107c9c <mappages+0x4c>
      return -1;
80107c95:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107c9a:	eb 48                	jmp    80107ce4 <mappages+0x94>
    if(*pte & PTE_P)
80107c9c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c9f:	8b 00                	mov    (%eax),%eax
80107ca1:	83 e0 01             	and    $0x1,%eax
80107ca4:	85 c0                	test   %eax,%eax
80107ca6:	74 0c                	je     80107cb4 <mappages+0x64>
      panic("remap");
80107ca8:	c7 04 24 cc 8e 10 80 	movl   $0x80108ecc,(%esp)
80107caf:	e8 a0 88 ff ff       	call   80100554 <panic>
    *pte = pa | perm | PTE_P;
80107cb4:	8b 45 18             	mov    0x18(%ebp),%eax
80107cb7:	0b 45 14             	or     0x14(%ebp),%eax
80107cba:	83 c8 01             	or     $0x1,%eax
80107cbd:	89 c2                	mov    %eax,%edx
80107cbf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107cc2:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107cc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc7:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107cca:	75 08                	jne    80107cd4 <mappages+0x84>
      break;
80107ccc:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80107ccd:	b8 00 00 00 00       	mov    $0x0,%eax
80107cd2:	eb 10                	jmp    80107ce4 <mappages+0x94>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
80107cd4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107cdb:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80107ce2:	eb 8e                	jmp    80107c72 <mappages+0x22>
  return 0;
}
80107ce4:	c9                   	leave  
80107ce5:	c3                   	ret    

80107ce6 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107ce6:	55                   	push   %ebp
80107ce7:	89 e5                	mov    %esp,%ebp
80107ce9:	53                   	push   %ebx
80107cea:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107ced:	e8 ed af ff ff       	call   80102cdf <kalloc>
80107cf2:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107cf5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107cf9:	75 0a                	jne    80107d05 <setupkvm+0x1f>
    return 0;
80107cfb:	b8 00 00 00 00       	mov    $0x0,%eax
80107d00:	e9 84 00 00 00       	jmp    80107d89 <setupkvm+0xa3>
  memset(pgdir, 0, PGSIZE);
80107d05:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107d0c:	00 
80107d0d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107d14:	00 
80107d15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d18:	89 04 24             	mov    %eax,(%esp)
80107d1b:	e8 fe d3 ff ff       	call   8010511e <memset>
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107d20:	c7 45 f4 c0 b4 10 80 	movl   $0x8010b4c0,-0xc(%ebp)
80107d27:	eb 54                	jmp    80107d7d <setupkvm+0x97>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107d29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d2c:	8b 48 0c             	mov    0xc(%eax),%ecx
80107d2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d32:	8b 50 04             	mov    0x4(%eax),%edx
80107d35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d38:	8b 58 08             	mov    0x8(%eax),%ebx
80107d3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d3e:	8b 40 04             	mov    0x4(%eax),%eax
80107d41:	29 c3                	sub    %eax,%ebx
80107d43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d46:	8b 00                	mov    (%eax),%eax
80107d48:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80107d4c:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107d50:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107d54:	89 44 24 04          	mov    %eax,0x4(%esp)
80107d58:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d5b:	89 04 24             	mov    %eax,(%esp)
80107d5e:	e8 ed fe ff ff       	call   80107c50 <mappages>
80107d63:	85 c0                	test   %eax,%eax
80107d65:	79 12                	jns    80107d79 <setupkvm+0x93>
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
80107d67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d6a:	89 04 24             	mov    %eax,(%esp)
80107d6d:	e8 1a 05 00 00       	call   8010828c <freevm>
      return 0;
80107d72:	b8 00 00 00 00       	mov    $0x0,%eax
80107d77:	eb 10                	jmp    80107d89 <setupkvm+0xa3>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107d79:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107d7d:	81 7d f4 00 b5 10 80 	cmpl   $0x8010b500,-0xc(%ebp)
80107d84:	72 a3                	jb     80107d29 <setupkvm+0x43>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
      return 0;
    }
  return pgdir;
80107d86:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107d89:	83 c4 34             	add    $0x34,%esp
80107d8c:	5b                   	pop    %ebx
80107d8d:	5d                   	pop    %ebp
80107d8e:	c3                   	ret    

80107d8f <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107d8f:	55                   	push   %ebp
80107d90:	89 e5                	mov    %esp,%ebp
80107d92:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107d95:	e8 4c ff ff ff       	call   80107ce6 <setupkvm>
80107d9a:	a3 c4 68 11 80       	mov    %eax,0x801168c4
  switchkvm();
80107d9f:	e8 02 00 00 00       	call   80107da6 <switchkvm>
}
80107da4:	c9                   	leave  
80107da5:	c3                   	ret    

80107da6 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107da6:	55                   	push   %ebp
80107da7:	89 e5                	mov    %esp,%ebp
80107da9:	83 ec 04             	sub    $0x4,%esp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107dac:	a1 c4 68 11 80       	mov    0x801168c4,%eax
80107db1:	05 00 00 00 80       	add    $0x80000000,%eax
80107db6:	89 04 24             	mov    %eax,(%esp)
80107db9:	e8 ae fa ff ff       	call   8010786c <lcr3>
}
80107dbe:	c9                   	leave  
80107dbf:	c3                   	ret    

80107dc0 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107dc0:	55                   	push   %ebp
80107dc1:	89 e5                	mov    %esp,%ebp
80107dc3:	57                   	push   %edi
80107dc4:	56                   	push   %esi
80107dc5:	53                   	push   %ebx
80107dc6:	83 ec 1c             	sub    $0x1c,%esp
  if(p == 0)
80107dc9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107dcd:	75 0c                	jne    80107ddb <switchuvm+0x1b>
    panic("switchuvm: no process");
80107dcf:	c7 04 24 d2 8e 10 80 	movl   $0x80108ed2,(%esp)
80107dd6:	e8 79 87 ff ff       	call   80100554 <panic>
  if(p->kstack == 0)
80107ddb:	8b 45 08             	mov    0x8(%ebp),%eax
80107dde:	8b 40 08             	mov    0x8(%eax),%eax
80107de1:	85 c0                	test   %eax,%eax
80107de3:	75 0c                	jne    80107df1 <switchuvm+0x31>
    panic("switchuvm: no kstack");
80107de5:	c7 04 24 e8 8e 10 80 	movl   $0x80108ee8,(%esp)
80107dec:	e8 63 87 ff ff       	call   80100554 <panic>
  if(p->pgdir == 0)
80107df1:	8b 45 08             	mov    0x8(%ebp),%eax
80107df4:	8b 40 04             	mov    0x4(%eax),%eax
80107df7:	85 c0                	test   %eax,%eax
80107df9:	75 0c                	jne    80107e07 <switchuvm+0x47>
    panic("switchuvm: no pgdir");
80107dfb:	c7 04 24 fd 8e 10 80 	movl   $0x80108efd,(%esp)
80107e02:	e8 4d 87 ff ff       	call   80100554 <panic>

  pushcli();
80107e07:	e8 0e d2 ff ff       	call   8010501a <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107e0c:	e8 0a c4 ff ff       	call   8010421b <mycpu>
80107e11:	89 c3                	mov    %eax,%ebx
80107e13:	e8 03 c4 ff ff       	call   8010421b <mycpu>
80107e18:	83 c0 08             	add    $0x8,%eax
80107e1b:	89 c6                	mov    %eax,%esi
80107e1d:	e8 f9 c3 ff ff       	call   8010421b <mycpu>
80107e22:	83 c0 08             	add    $0x8,%eax
80107e25:	c1 e8 10             	shr    $0x10,%eax
80107e28:	89 c7                	mov    %eax,%edi
80107e2a:	e8 ec c3 ff ff       	call   8010421b <mycpu>
80107e2f:	83 c0 08             	add    $0x8,%eax
80107e32:	c1 e8 18             	shr    $0x18,%eax
80107e35:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107e3c:	67 00 
80107e3e:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107e45:	89 f9                	mov    %edi,%ecx
80107e47:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80107e4d:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80107e53:	83 e2 f0             	and    $0xfffffff0,%edx
80107e56:	83 ca 09             	or     $0x9,%edx
80107e59:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80107e5f:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80107e65:	83 ca 10             	or     $0x10,%edx
80107e68:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80107e6e:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80107e74:	83 e2 9f             	and    $0xffffff9f,%edx
80107e77:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80107e7d:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80107e83:	83 ca 80             	or     $0xffffff80,%edx
80107e86:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80107e8c:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80107e92:	83 e2 f0             	and    $0xfffffff0,%edx
80107e95:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80107e9b:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80107ea1:	83 e2 ef             	and    $0xffffffef,%edx
80107ea4:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80107eaa:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80107eb0:	83 e2 df             	and    $0xffffffdf,%edx
80107eb3:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80107eb9:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80107ebf:	83 ca 40             	or     $0x40,%edx
80107ec2:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80107ec8:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80107ece:	83 e2 7f             	and    $0x7f,%edx
80107ed1:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80107ed7:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107edd:	e8 39 c3 ff ff       	call   8010421b <mycpu>
80107ee2:	8a 90 9d 00 00 00    	mov    0x9d(%eax),%dl
80107ee8:	83 e2 ef             	and    $0xffffffef,%edx
80107eeb:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107ef1:	e8 25 c3 ff ff       	call   8010421b <mycpu>
80107ef6:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107efc:	e8 1a c3 ff ff       	call   8010421b <mycpu>
80107f01:	8b 55 08             	mov    0x8(%ebp),%edx
80107f04:	8b 52 08             	mov    0x8(%edx),%edx
80107f07:	81 c2 00 10 00 00    	add    $0x1000,%edx
80107f0d:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107f10:	e8 06 c3 ff ff       	call   8010421b <mycpu>
80107f15:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107f1b:	c7 04 24 28 00 00 00 	movl   $0x28,(%esp)
80107f22:	e8 30 f9 ff ff       	call   80107857 <ltr>
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107f27:	8b 45 08             	mov    0x8(%ebp),%eax
80107f2a:	8b 40 04             	mov    0x4(%eax),%eax
80107f2d:	05 00 00 00 80       	add    $0x80000000,%eax
80107f32:	89 04 24             	mov    %eax,(%esp)
80107f35:	e8 32 f9 ff ff       	call   8010786c <lcr3>
  popcli();
80107f3a:	e8 25 d1 ff ff       	call   80105064 <popcli>
}
80107f3f:	83 c4 1c             	add    $0x1c,%esp
80107f42:	5b                   	pop    %ebx
80107f43:	5e                   	pop    %esi
80107f44:	5f                   	pop    %edi
80107f45:	5d                   	pop    %ebp
80107f46:	c3                   	ret    

80107f47 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107f47:	55                   	push   %ebp
80107f48:	89 e5                	mov    %esp,%ebp
80107f4a:	83 ec 38             	sub    $0x38,%esp
  char *mem;

  if(sz >= PGSIZE)
80107f4d:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107f54:	76 0c                	jbe    80107f62 <inituvm+0x1b>
    panic("inituvm: more than a page");
80107f56:	c7 04 24 11 8f 10 80 	movl   $0x80108f11,(%esp)
80107f5d:	e8 f2 85 ff ff       	call   80100554 <panic>
  mem = kalloc();
80107f62:	e8 78 ad ff ff       	call   80102cdf <kalloc>
80107f67:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107f6a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107f71:	00 
80107f72:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107f79:	00 
80107f7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f7d:	89 04 24             	mov    %eax,(%esp)
80107f80:	e8 99 d1 ff ff       	call   8010511e <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107f85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f88:	05 00 00 00 80       	add    $0x80000000,%eax
80107f8d:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80107f94:	00 
80107f95:	89 44 24 0c          	mov    %eax,0xc(%esp)
80107f99:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107fa0:	00 
80107fa1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107fa8:	00 
80107fa9:	8b 45 08             	mov    0x8(%ebp),%eax
80107fac:	89 04 24             	mov    %eax,(%esp)
80107faf:	e8 9c fc ff ff       	call   80107c50 <mappages>
  memmove(mem, init, sz);
80107fb4:	8b 45 10             	mov    0x10(%ebp),%eax
80107fb7:	89 44 24 08          	mov    %eax,0x8(%esp)
80107fbb:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fbe:	89 44 24 04          	mov    %eax,0x4(%esp)
80107fc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fc5:	89 04 24             	mov    %eax,(%esp)
80107fc8:	e8 1a d2 ff ff       	call   801051e7 <memmove>
}
80107fcd:	c9                   	leave  
80107fce:	c3                   	ret    

80107fcf <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107fcf:	55                   	push   %ebp
80107fd0:	89 e5                	mov    %esp,%ebp
80107fd2:	83 ec 28             	sub    $0x28,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107fd5:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fd8:	25 ff 0f 00 00       	and    $0xfff,%eax
80107fdd:	85 c0                	test   %eax,%eax
80107fdf:	74 0c                	je     80107fed <loaduvm+0x1e>
    panic("loaduvm: addr must be page aligned");
80107fe1:	c7 04 24 2c 8f 10 80 	movl   $0x80108f2c,(%esp)
80107fe8:	e8 67 85 ff ff       	call   80100554 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107fed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107ff4:	e9 a6 00 00 00       	jmp    8010809f <loaduvm+0xd0>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107ff9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ffc:	8b 55 0c             	mov    0xc(%ebp),%edx
80107fff:	01 d0                	add    %edx,%eax
80108001:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108008:	00 
80108009:	89 44 24 04          	mov    %eax,0x4(%esp)
8010800d:	8b 45 08             	mov    0x8(%ebp),%eax
80108010:	89 04 24             	mov    %eax,(%esp)
80108013:	e8 9c fb ff ff       	call   80107bb4 <walkpgdir>
80108018:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010801b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010801f:	75 0c                	jne    8010802d <loaduvm+0x5e>
      panic("loaduvm: address should exist");
80108021:	c7 04 24 4f 8f 10 80 	movl   $0x80108f4f,(%esp)
80108028:	e8 27 85 ff ff       	call   80100554 <panic>
    pa = PTE_ADDR(*pte);
8010802d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108030:	8b 00                	mov    (%eax),%eax
80108032:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108037:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
8010803a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010803d:	8b 55 18             	mov    0x18(%ebp),%edx
80108040:	29 c2                	sub    %eax,%edx
80108042:	89 d0                	mov    %edx,%eax
80108044:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108049:	77 0f                	ja     8010805a <loaduvm+0x8b>
      n = sz - i;
8010804b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010804e:	8b 55 18             	mov    0x18(%ebp),%edx
80108051:	29 c2                	sub    %eax,%edx
80108053:	89 d0                	mov    %edx,%eax
80108055:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108058:	eb 07                	jmp    80108061 <loaduvm+0x92>
    else
      n = PGSIZE;
8010805a:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80108061:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108064:	8b 55 14             	mov    0x14(%ebp),%edx
80108067:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
8010806a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010806d:	05 00 00 00 80       	add    $0x80000000,%eax
80108072:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108075:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108079:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010807d:	89 44 24 04          	mov    %eax,0x4(%esp)
80108081:	8b 45 10             	mov    0x10(%ebp),%eax
80108084:	89 04 24             	mov    %eax,(%esp)
80108087:	e8 b9 9e ff ff       	call   80101f45 <readi>
8010808c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010808f:	74 07                	je     80108098 <loaduvm+0xc9>
      return -1;
80108091:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108096:	eb 18                	jmp    801080b0 <loaduvm+0xe1>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108098:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010809f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080a2:	3b 45 18             	cmp    0x18(%ebp),%eax
801080a5:	0f 82 4e ff ff ff    	jb     80107ff9 <loaduvm+0x2a>
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
801080ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
801080b0:	c9                   	leave  
801080b1:	c3                   	ret    

801080b2 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801080b2:	55                   	push   %ebp
801080b3:	89 e5                	mov    %esp,%ebp
801080b5:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
801080b8:	8b 45 10             	mov    0x10(%ebp),%eax
801080bb:	85 c0                	test   %eax,%eax
801080bd:	79 0a                	jns    801080c9 <allocuvm+0x17>
    return 0;
801080bf:	b8 00 00 00 00       	mov    $0x0,%eax
801080c4:	e9 fd 00 00 00       	jmp    801081c6 <allocuvm+0x114>
  if(newsz < oldsz)
801080c9:	8b 45 10             	mov    0x10(%ebp),%eax
801080cc:	3b 45 0c             	cmp    0xc(%ebp),%eax
801080cf:	73 08                	jae    801080d9 <allocuvm+0x27>
    return oldsz;
801080d1:	8b 45 0c             	mov    0xc(%ebp),%eax
801080d4:	e9 ed 00 00 00       	jmp    801081c6 <allocuvm+0x114>

  a = PGROUNDUP(oldsz);
801080d9:	8b 45 0c             	mov    0xc(%ebp),%eax
801080dc:	05 ff 0f 00 00       	add    $0xfff,%eax
801080e1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801080e9:	e9 c9 00 00 00       	jmp    801081b7 <allocuvm+0x105>
    mem = kalloc();
801080ee:	e8 ec ab ff ff       	call   80102cdf <kalloc>
801080f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801080f6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801080fa:	75 2f                	jne    8010812b <allocuvm+0x79>
      cprintf("allocuvm out of memory\n");
801080fc:	c7 04 24 6d 8f 10 80 	movl   $0x80108f6d,(%esp)
80108103:	e8 b9 82 ff ff       	call   801003c1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108108:	8b 45 0c             	mov    0xc(%ebp),%eax
8010810b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010810f:	8b 45 10             	mov    0x10(%ebp),%eax
80108112:	89 44 24 04          	mov    %eax,0x4(%esp)
80108116:	8b 45 08             	mov    0x8(%ebp),%eax
80108119:	89 04 24             	mov    %eax,(%esp)
8010811c:	e8 a7 00 00 00       	call   801081c8 <deallocuvm>
      return 0;
80108121:	b8 00 00 00 00       	mov    $0x0,%eax
80108126:	e9 9b 00 00 00       	jmp    801081c6 <allocuvm+0x114>
    }
    memset(mem, 0, PGSIZE);
8010812b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108132:	00 
80108133:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010813a:	00 
8010813b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010813e:	89 04 24             	mov    %eax,(%esp)
80108141:	e8 d8 cf ff ff       	call   8010511e <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80108146:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108149:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
8010814f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108152:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108159:	00 
8010815a:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010815e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108165:	00 
80108166:	89 44 24 04          	mov    %eax,0x4(%esp)
8010816a:	8b 45 08             	mov    0x8(%ebp),%eax
8010816d:	89 04 24             	mov    %eax,(%esp)
80108170:	e8 db fa ff ff       	call   80107c50 <mappages>
80108175:	85 c0                	test   %eax,%eax
80108177:	79 37                	jns    801081b0 <allocuvm+0xfe>
      cprintf("allocuvm out of memory (2)\n");
80108179:	c7 04 24 85 8f 10 80 	movl   $0x80108f85,(%esp)
80108180:	e8 3c 82 ff ff       	call   801003c1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108185:	8b 45 0c             	mov    0xc(%ebp),%eax
80108188:	89 44 24 08          	mov    %eax,0x8(%esp)
8010818c:	8b 45 10             	mov    0x10(%ebp),%eax
8010818f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108193:	8b 45 08             	mov    0x8(%ebp),%eax
80108196:	89 04 24             	mov    %eax,(%esp)
80108199:	e8 2a 00 00 00       	call   801081c8 <deallocuvm>
      kfree(mem);
8010819e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081a1:	89 04 24             	mov    %eax,(%esp)
801081a4:	e8 a0 aa ff ff       	call   80102c49 <kfree>
      return 0;
801081a9:	b8 00 00 00 00       	mov    $0x0,%eax
801081ae:	eb 16                	jmp    801081c6 <allocuvm+0x114>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
801081b0:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801081b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081ba:	3b 45 10             	cmp    0x10(%ebp),%eax
801081bd:	0f 82 2b ff ff ff    	jb     801080ee <allocuvm+0x3c>
      deallocuvm(pgdir, newsz, oldsz);
      kfree(mem);
      return 0;
    }
  }
  return newsz;
801081c3:	8b 45 10             	mov    0x10(%ebp),%eax
}
801081c6:	c9                   	leave  
801081c7:	c3                   	ret    

801081c8 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801081c8:	55                   	push   %ebp
801081c9:	89 e5                	mov    %esp,%ebp
801081cb:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801081ce:	8b 45 10             	mov    0x10(%ebp),%eax
801081d1:	3b 45 0c             	cmp    0xc(%ebp),%eax
801081d4:	72 08                	jb     801081de <deallocuvm+0x16>
    return oldsz;
801081d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801081d9:	e9 ac 00 00 00       	jmp    8010828a <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
801081de:	8b 45 10             	mov    0x10(%ebp),%eax
801081e1:	05 ff 0f 00 00       	add    $0xfff,%eax
801081e6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801081eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801081ee:	e9 88 00 00 00       	jmp    8010827b <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
801081f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081f6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801081fd:	00 
801081fe:	89 44 24 04          	mov    %eax,0x4(%esp)
80108202:	8b 45 08             	mov    0x8(%ebp),%eax
80108205:	89 04 24             	mov    %eax,(%esp)
80108208:	e8 a7 f9 ff ff       	call   80107bb4 <walkpgdir>
8010820d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108210:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108214:	75 14                	jne    8010822a <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80108216:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108219:	c1 e8 16             	shr    $0x16,%eax
8010821c:	40                   	inc    %eax
8010821d:	c1 e0 16             	shl    $0x16,%eax
80108220:	2d 00 10 00 00       	sub    $0x1000,%eax
80108225:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108228:	eb 4a                	jmp    80108274 <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
8010822a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010822d:	8b 00                	mov    (%eax),%eax
8010822f:	83 e0 01             	and    $0x1,%eax
80108232:	85 c0                	test   %eax,%eax
80108234:	74 3e                	je     80108274 <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80108236:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108239:	8b 00                	mov    (%eax),%eax
8010823b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108240:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108243:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108247:	75 0c                	jne    80108255 <deallocuvm+0x8d>
        panic("kfree");
80108249:	c7 04 24 a1 8f 10 80 	movl   $0x80108fa1,(%esp)
80108250:	e8 ff 82 ff ff       	call   80100554 <panic>
      char *v = P2V(pa);
80108255:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108258:	05 00 00 00 80       	add    $0x80000000,%eax
8010825d:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108260:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108263:	89 04 24             	mov    %eax,(%esp)
80108266:	e8 de a9 ff ff       	call   80102c49 <kfree>
      *pte = 0;
8010826b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010826e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108274:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010827b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010827e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108281:	0f 82 6c ff ff ff    	jb     801081f3 <deallocuvm+0x2b>
      char *v = P2V(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108287:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010828a:	c9                   	leave  
8010828b:	c3                   	ret    

8010828c <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010828c:	55                   	push   %ebp
8010828d:	89 e5                	mov    %esp,%ebp
8010828f:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
80108292:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108296:	75 0c                	jne    801082a4 <freevm+0x18>
    panic("freevm: no pgdir");
80108298:	c7 04 24 a7 8f 10 80 	movl   $0x80108fa7,(%esp)
8010829f:	e8 b0 82 ff ff       	call   80100554 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801082a4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801082ab:	00 
801082ac:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
801082b3:	80 
801082b4:	8b 45 08             	mov    0x8(%ebp),%eax
801082b7:	89 04 24             	mov    %eax,(%esp)
801082ba:	e8 09 ff ff ff       	call   801081c8 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
801082bf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801082c6:	eb 44                	jmp    8010830c <freevm+0x80>
    if(pgdir[i] & PTE_P){
801082c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082cb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801082d2:	8b 45 08             	mov    0x8(%ebp),%eax
801082d5:	01 d0                	add    %edx,%eax
801082d7:	8b 00                	mov    (%eax),%eax
801082d9:	83 e0 01             	and    $0x1,%eax
801082dc:	85 c0                	test   %eax,%eax
801082de:	74 29                	je     80108309 <freevm+0x7d>
      char * v = P2V(PTE_ADDR(pgdir[i]));
801082e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082e3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801082ea:	8b 45 08             	mov    0x8(%ebp),%eax
801082ed:	01 d0                	add    %edx,%eax
801082ef:	8b 00                	mov    (%eax),%eax
801082f1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801082f6:	05 00 00 00 80       	add    $0x80000000,%eax
801082fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801082fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108301:	89 04 24             	mov    %eax,(%esp)
80108304:	e8 40 a9 ff ff       	call   80102c49 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108309:	ff 45 f4             	incl   -0xc(%ebp)
8010830c:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108313:	76 b3                	jbe    801082c8 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80108315:	8b 45 08             	mov    0x8(%ebp),%eax
80108318:	89 04 24             	mov    %eax,(%esp)
8010831b:	e8 29 a9 ff ff       	call   80102c49 <kfree>
}
80108320:	c9                   	leave  
80108321:	c3                   	ret    

80108322 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108322:	55                   	push   %ebp
80108323:	89 e5                	mov    %esp,%ebp
80108325:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108328:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010832f:	00 
80108330:	8b 45 0c             	mov    0xc(%ebp),%eax
80108333:	89 44 24 04          	mov    %eax,0x4(%esp)
80108337:	8b 45 08             	mov    0x8(%ebp),%eax
8010833a:	89 04 24             	mov    %eax,(%esp)
8010833d:	e8 72 f8 ff ff       	call   80107bb4 <walkpgdir>
80108342:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108345:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108349:	75 0c                	jne    80108357 <clearpteu+0x35>
    panic("clearpteu");
8010834b:	c7 04 24 b8 8f 10 80 	movl   $0x80108fb8,(%esp)
80108352:	e8 fd 81 ff ff       	call   80100554 <panic>
  *pte &= ~PTE_U;
80108357:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010835a:	8b 00                	mov    (%eax),%eax
8010835c:	83 e0 fb             	and    $0xfffffffb,%eax
8010835f:	89 c2                	mov    %eax,%edx
80108361:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108364:	89 10                	mov    %edx,(%eax)
}
80108366:	c9                   	leave  
80108367:	c3                   	ret    

80108368 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108368:	55                   	push   %ebp
80108369:	89 e5                	mov    %esp,%ebp
8010836b:	83 ec 48             	sub    $0x48,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
8010836e:	e8 73 f9 ff ff       	call   80107ce6 <setupkvm>
80108373:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108376:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010837a:	75 0a                	jne    80108386 <copyuvm+0x1e>
    return 0;
8010837c:	b8 00 00 00 00       	mov    $0x0,%eax
80108381:	e9 f8 00 00 00       	jmp    8010847e <copyuvm+0x116>
  for(i = 0; i < sz; i += PGSIZE){
80108386:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010838d:	e9 cb 00 00 00       	jmp    8010845d <copyuvm+0xf5>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108392:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108395:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010839c:	00 
8010839d:	89 44 24 04          	mov    %eax,0x4(%esp)
801083a1:	8b 45 08             	mov    0x8(%ebp),%eax
801083a4:	89 04 24             	mov    %eax,(%esp)
801083a7:	e8 08 f8 ff ff       	call   80107bb4 <walkpgdir>
801083ac:	89 45 ec             	mov    %eax,-0x14(%ebp)
801083af:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801083b3:	75 0c                	jne    801083c1 <copyuvm+0x59>
      panic("copyuvm: pte should exist");
801083b5:	c7 04 24 c2 8f 10 80 	movl   $0x80108fc2,(%esp)
801083bc:	e8 93 81 ff ff       	call   80100554 <panic>
    if(!(*pte & PTE_P))
801083c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083c4:	8b 00                	mov    (%eax),%eax
801083c6:	83 e0 01             	and    $0x1,%eax
801083c9:	85 c0                	test   %eax,%eax
801083cb:	75 0c                	jne    801083d9 <copyuvm+0x71>
      panic("copyuvm: page not present");
801083cd:	c7 04 24 dc 8f 10 80 	movl   $0x80108fdc,(%esp)
801083d4:	e8 7b 81 ff ff       	call   80100554 <panic>
    pa = PTE_ADDR(*pte);
801083d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083dc:	8b 00                	mov    (%eax),%eax
801083de:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083e3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801083e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083e9:	8b 00                	mov    (%eax),%eax
801083eb:	25 ff 0f 00 00       	and    $0xfff,%eax
801083f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801083f3:	e8 e7 a8 ff ff       	call   80102cdf <kalloc>
801083f8:	89 45 e0             	mov    %eax,-0x20(%ebp)
801083fb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801083ff:	75 02                	jne    80108403 <copyuvm+0x9b>
      goto bad;
80108401:	eb 6b                	jmp    8010846e <copyuvm+0x106>
    memmove(mem, (char*)P2V(pa), PGSIZE);
80108403:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108406:	05 00 00 00 80       	add    $0x80000000,%eax
8010840b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108412:	00 
80108413:	89 44 24 04          	mov    %eax,0x4(%esp)
80108417:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010841a:	89 04 24             	mov    %eax,(%esp)
8010841d:	e8 c5 cd ff ff       	call   801051e7 <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80108422:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108425:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108428:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
8010842e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108431:	89 54 24 10          	mov    %edx,0x10(%esp)
80108435:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80108439:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108440:	00 
80108441:	89 44 24 04          	mov    %eax,0x4(%esp)
80108445:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108448:	89 04 24             	mov    %eax,(%esp)
8010844b:	e8 00 f8 ff ff       	call   80107c50 <mappages>
80108450:	85 c0                	test   %eax,%eax
80108452:	79 02                	jns    80108456 <copyuvm+0xee>
      goto bad;
80108454:	eb 18                	jmp    8010846e <copyuvm+0x106>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108456:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010845d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108460:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108463:	0f 82 29 ff ff ff    	jb     80108392 <copyuvm+0x2a>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
      goto bad;
  }
  return d;
80108469:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010846c:	eb 10                	jmp    8010847e <copyuvm+0x116>

bad:
  freevm(d);
8010846e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108471:	89 04 24             	mov    %eax,(%esp)
80108474:	e8 13 fe ff ff       	call   8010828c <freevm>
  return 0;
80108479:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010847e:	c9                   	leave  
8010847f:	c3                   	ret    

80108480 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108480:	55                   	push   %ebp
80108481:	89 e5                	mov    %esp,%ebp
80108483:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108486:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010848d:	00 
8010848e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108491:	89 44 24 04          	mov    %eax,0x4(%esp)
80108495:	8b 45 08             	mov    0x8(%ebp),%eax
80108498:	89 04 24             	mov    %eax,(%esp)
8010849b:	e8 14 f7 ff ff       	call   80107bb4 <walkpgdir>
801084a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801084a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084a6:	8b 00                	mov    (%eax),%eax
801084a8:	83 e0 01             	and    $0x1,%eax
801084ab:	85 c0                	test   %eax,%eax
801084ad:	75 07                	jne    801084b6 <uva2ka+0x36>
    return 0;
801084af:	b8 00 00 00 00       	mov    $0x0,%eax
801084b4:	eb 22                	jmp    801084d8 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
801084b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084b9:	8b 00                	mov    (%eax),%eax
801084bb:	83 e0 04             	and    $0x4,%eax
801084be:	85 c0                	test   %eax,%eax
801084c0:	75 07                	jne    801084c9 <uva2ka+0x49>
    return 0;
801084c2:	b8 00 00 00 00       	mov    $0x0,%eax
801084c7:	eb 0f                	jmp    801084d8 <uva2ka+0x58>
  return (char*)P2V(PTE_ADDR(*pte));
801084c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084cc:	8b 00                	mov    (%eax),%eax
801084ce:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084d3:	05 00 00 00 80       	add    $0x80000000,%eax
}
801084d8:	c9                   	leave  
801084d9:	c3                   	ret    

801084da <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801084da:	55                   	push   %ebp
801084db:	89 e5                	mov    %esp,%ebp
801084dd:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801084e0:	8b 45 10             	mov    0x10(%ebp),%eax
801084e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801084e6:	e9 87 00 00 00       	jmp    80108572 <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
801084eb:	8b 45 0c             	mov    0xc(%ebp),%eax
801084ee:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801084f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084f9:	89 44 24 04          	mov    %eax,0x4(%esp)
801084fd:	8b 45 08             	mov    0x8(%ebp),%eax
80108500:	89 04 24             	mov    %eax,(%esp)
80108503:	e8 78 ff ff ff       	call   80108480 <uva2ka>
80108508:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
8010850b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010850f:	75 07                	jne    80108518 <copyout+0x3e>
      return -1;
80108511:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108516:	eb 69                	jmp    80108581 <copyout+0xa7>
    n = PGSIZE - (va - va0);
80108518:	8b 45 0c             	mov    0xc(%ebp),%eax
8010851b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010851e:	29 c2                	sub    %eax,%edx
80108520:	89 d0                	mov    %edx,%eax
80108522:	05 00 10 00 00       	add    $0x1000,%eax
80108527:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010852a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010852d:	3b 45 14             	cmp    0x14(%ebp),%eax
80108530:	76 06                	jbe    80108538 <copyout+0x5e>
      n = len;
80108532:	8b 45 14             	mov    0x14(%ebp),%eax
80108535:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108538:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010853b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010853e:	29 c2                	sub    %eax,%edx
80108540:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108543:	01 c2                	add    %eax,%edx
80108545:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108548:	89 44 24 08          	mov    %eax,0x8(%esp)
8010854c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010854f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108553:	89 14 24             	mov    %edx,(%esp)
80108556:	e8 8c cc ff ff       	call   801051e7 <memmove>
    len -= n;
8010855b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010855e:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108561:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108564:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108567:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010856a:	05 00 10 00 00       	add    $0x1000,%eax
8010856f:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108572:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108576:	0f 85 6f ff ff ff    	jne    801084eb <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
8010857c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108581:	c9                   	leave  
80108582:	c3                   	ret    
	...

80108584 <strcpy>:

#define MAX_CONTAINERS 4

struct container containers[MAX_CONTAINERS];

char* strcpy(char *s, char *t){
80108584:	55                   	push   %ebp
80108585:	89 e5                	mov    %esp,%ebp
80108587:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
8010858a:	8b 45 08             	mov    0x8(%ebp),%eax
8010858d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
80108590:	90                   	nop
80108591:	8b 45 08             	mov    0x8(%ebp),%eax
80108594:	8d 50 01             	lea    0x1(%eax),%edx
80108597:	89 55 08             	mov    %edx,0x8(%ebp)
8010859a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010859d:	8d 4a 01             	lea    0x1(%edx),%ecx
801085a0:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801085a3:	8a 12                	mov    (%edx),%dl
801085a5:	88 10                	mov    %dl,(%eax)
801085a7:	8a 00                	mov    (%eax),%al
801085a9:	84 c0                	test   %al,%al
801085ab:	75 e4                	jne    80108591 <strcpy+0xd>
    ;
  return os;
801085ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801085b0:	c9                   	leave  
801085b1:	c3                   	ret    

801085b2 <get_name>:

void get_name(char* name, int vc_num){
801085b2:	55                   	push   %ebp
801085b3:	89 e5                	mov    %esp,%ebp
801085b5:	57                   	push   %edi
801085b6:	56                   	push   %esi
801085b7:	53                   	push   %ebx
801085b8:	83 ec 28             	sub    $0x28,%esp

	struct container x = containers[vc_num];
801085bb:	8b 55 0c             	mov    0xc(%ebp),%edx
801085be:	89 d0                	mov    %edx,%eax
801085c0:	01 c0                	add    %eax,%eax
801085c2:	01 d0                	add    %edx,%eax
801085c4:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
801085cb:	01 c8                	add    %ecx,%eax
801085cd:	01 d0                	add    %edx,%eax
801085cf:	05 e0 68 11 80       	add    $0x801168e0,%eax
801085d4:	8d 55 d8             	lea    -0x28(%ebp),%edx
801085d7:	89 c3                	mov    %eax,%ebx
801085d9:	b8 07 00 00 00       	mov    $0x7,%eax
801085de:	89 d7                	mov    %edx,%edi
801085e0:	89 de                	mov    %ebx,%esi
801085e2:	89 c1                	mov    %eax,%ecx
801085e4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	strcpy(name, x.name);
801085e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085e9:	89 44 24 04          	mov    %eax,0x4(%esp)
801085ed:	8b 45 08             	mov    0x8(%ebp),%eax
801085f0:	89 04 24             	mov    %eax,(%esp)
801085f3:	e8 8c ff ff ff       	call   80108584 <strcpy>
}
801085f8:	83 c4 28             	add    $0x28,%esp
801085fb:	5b                   	pop    %ebx
801085fc:	5e                   	pop    %esi
801085fd:	5f                   	pop    %edi
801085fe:	5d                   	pop    %ebp
801085ff:	c3                   	ret    

80108600 <get_max_proc>:

int get_max_proc(int vc_num){
80108600:	55                   	push   %ebp
80108601:	89 e5                	mov    %esp,%ebp
80108603:	57                   	push   %edi
80108604:	56                   	push   %esi
80108605:	53                   	push   %ebx
80108606:	83 ec 20             	sub    $0x20,%esp
	struct container x = containers[vc_num];
80108609:	8b 55 08             	mov    0x8(%ebp),%edx
8010860c:	89 d0                	mov    %edx,%eax
8010860e:	01 c0                	add    %eax,%eax
80108610:	01 d0                	add    %edx,%eax
80108612:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
80108619:	01 c8                	add    %ecx,%eax
8010861b:	01 d0                	add    %edx,%eax
8010861d:	05 e0 68 11 80       	add    $0x801168e0,%eax
80108622:	8d 55 d8             	lea    -0x28(%ebp),%edx
80108625:	89 c3                	mov    %eax,%ebx
80108627:	b8 07 00 00 00       	mov    $0x7,%eax
8010862c:	89 d7                	mov    %edx,%edi
8010862e:	89 de                	mov    %ebx,%esi
80108630:	89 c1                	mov    %eax,%ecx
80108632:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.max_proc;
80108634:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
80108637:	83 c4 20             	add    $0x20,%esp
8010863a:	5b                   	pop    %ebx
8010863b:	5e                   	pop    %esi
8010863c:	5f                   	pop    %edi
8010863d:	5d                   	pop    %ebp
8010863e:	c3                   	ret    

8010863f <get_max_mem>:

int get_max_mem(int vc_num){
8010863f:	55                   	push   %ebp
80108640:	89 e5                	mov    %esp,%ebp
80108642:	57                   	push   %edi
80108643:	56                   	push   %esi
80108644:	53                   	push   %ebx
80108645:	83 ec 20             	sub    $0x20,%esp
	struct container x = containers[vc_num];
80108648:	8b 55 08             	mov    0x8(%ebp),%edx
8010864b:	89 d0                	mov    %edx,%eax
8010864d:	01 c0                	add    %eax,%eax
8010864f:	01 d0                	add    %edx,%eax
80108651:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
80108658:	01 c8                	add    %ecx,%eax
8010865a:	01 d0                	add    %edx,%eax
8010865c:	05 e0 68 11 80       	add    $0x801168e0,%eax
80108661:	8d 55 d8             	lea    -0x28(%ebp),%edx
80108664:	89 c3                	mov    %eax,%ebx
80108666:	b8 07 00 00 00       	mov    $0x7,%eax
8010866b:	89 d7                	mov    %edx,%edi
8010866d:	89 de                	mov    %ebx,%esi
8010866f:	89 c1                	mov    %eax,%ecx
80108671:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.max_mem; 
80108673:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80108676:	83 c4 20             	add    $0x20,%esp
80108679:	5b                   	pop    %ebx
8010867a:	5e                   	pop    %esi
8010867b:	5f                   	pop    %edi
8010867c:	5d                   	pop    %ebp
8010867d:	c3                   	ret    

8010867e <get_max_disk>:

int get_max_disk(int vc_num){
8010867e:	55                   	push   %ebp
8010867f:	89 e5                	mov    %esp,%ebp
80108681:	57                   	push   %edi
80108682:	56                   	push   %esi
80108683:	53                   	push   %ebx
80108684:	83 ec 20             	sub    $0x20,%esp
	struct container x = containers[vc_num];
80108687:	8b 55 08             	mov    0x8(%ebp),%edx
8010868a:	89 d0                	mov    %edx,%eax
8010868c:	01 c0                	add    %eax,%eax
8010868e:	01 d0                	add    %edx,%eax
80108690:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
80108697:	01 c8                	add    %ecx,%eax
80108699:	01 d0                	add    %edx,%eax
8010869b:	05 e0 68 11 80       	add    $0x801168e0,%eax
801086a0:	8d 55 d8             	lea    -0x28(%ebp),%edx
801086a3:	89 c3                	mov    %eax,%ebx
801086a5:	b8 07 00 00 00       	mov    $0x7,%eax
801086aa:	89 d7                	mov    %edx,%edi
801086ac:	89 de                	mov    %ebx,%esi
801086ae:	89 c1                	mov    %eax,%ecx
801086b0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.max_disk;
801086b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
801086b5:	83 c4 20             	add    $0x20,%esp
801086b8:	5b                   	pop    %ebx
801086b9:	5e                   	pop    %esi
801086ba:	5f                   	pop    %edi
801086bb:	5d                   	pop    %ebp
801086bc:	c3                   	ret    

801086bd <get_curr_proc>:

int get_curr_proc(int vc_num){
801086bd:	55                   	push   %ebp
801086be:	89 e5                	mov    %esp,%ebp
801086c0:	57                   	push   %edi
801086c1:	56                   	push   %esi
801086c2:	53                   	push   %ebx
801086c3:	83 ec 20             	sub    $0x20,%esp
	struct container x = containers[vc_num];
801086c6:	8b 55 08             	mov    0x8(%ebp),%edx
801086c9:	89 d0                	mov    %edx,%eax
801086cb:	01 c0                	add    %eax,%eax
801086cd:	01 d0                	add    %edx,%eax
801086cf:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
801086d6:	01 c8                	add    %ecx,%eax
801086d8:	01 d0                	add    %edx,%eax
801086da:	05 e0 68 11 80       	add    $0x801168e0,%eax
801086df:	8d 55 d8             	lea    -0x28(%ebp),%edx
801086e2:	89 c3                	mov    %eax,%ebx
801086e4:	b8 07 00 00 00       	mov    $0x7,%eax
801086e9:	89 d7                	mov    %edx,%edi
801086eb:	89 de                	mov    %ebx,%esi
801086ed:	89 c1                	mov    %eax,%ecx
801086ef:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.curr_proc;
801086f1:	8b 45 e8             	mov    -0x18(%ebp),%eax
}
801086f4:	83 c4 20             	add    $0x20,%esp
801086f7:	5b                   	pop    %ebx
801086f8:	5e                   	pop    %esi
801086f9:	5f                   	pop    %edi
801086fa:	5d                   	pop    %ebp
801086fb:	c3                   	ret    

801086fc <get_curr_mem>:

int get_curr_mem(int vc_num){
801086fc:	55                   	push   %ebp
801086fd:	89 e5                	mov    %esp,%ebp
801086ff:	57                   	push   %edi
80108700:	56                   	push   %esi
80108701:	53                   	push   %ebx
80108702:	83 ec 20             	sub    $0x20,%esp
	struct container x = containers[vc_num];
80108705:	8b 55 08             	mov    0x8(%ebp),%edx
80108708:	89 d0                	mov    %edx,%eax
8010870a:	01 c0                	add    %eax,%eax
8010870c:	01 d0                	add    %edx,%eax
8010870e:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
80108715:	01 c8                	add    %ecx,%eax
80108717:	01 d0                	add    %edx,%eax
80108719:	05 e0 68 11 80       	add    $0x801168e0,%eax
8010871e:	8d 55 d8             	lea    -0x28(%ebp),%edx
80108721:	89 c3                	mov    %eax,%ebx
80108723:	b8 07 00 00 00       	mov    $0x7,%eax
80108728:	89 d7                	mov    %edx,%edi
8010872a:	89 de                	mov    %ebx,%esi
8010872c:	89 c1                	mov    %eax,%ecx
8010872e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.curr_mem; 
80108730:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
80108733:	83 c4 20             	add    $0x20,%esp
80108736:	5b                   	pop    %ebx
80108737:	5e                   	pop    %esi
80108738:	5f                   	pop    %edi
80108739:	5d                   	pop    %ebp
8010873a:	c3                   	ret    

8010873b <get_curr_disk>:

int get_curr_disk(int vc_num){
8010873b:	55                   	push   %ebp
8010873c:	89 e5                	mov    %esp,%ebp
8010873e:	57                   	push   %edi
8010873f:	56                   	push   %esi
80108740:	53                   	push   %ebx
80108741:	83 ec 20             	sub    $0x20,%esp
	struct container x = containers[vc_num];
80108744:	8b 55 08             	mov    0x8(%ebp),%edx
80108747:	89 d0                	mov    %edx,%eax
80108749:	01 c0                	add    %eax,%eax
8010874b:	01 d0                	add    %edx,%eax
8010874d:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
80108754:	01 c8                	add    %ecx,%eax
80108756:	01 d0                	add    %edx,%eax
80108758:	05 e0 68 11 80       	add    $0x801168e0,%eax
8010875d:	8d 55 d8             	lea    -0x28(%ebp),%edx
80108760:	89 c3                	mov    %eax,%ebx
80108762:	b8 07 00 00 00       	mov    $0x7,%eax
80108767:	89 d7                	mov    %edx,%edi
80108769:	89 de                	mov    %ebx,%esi
8010876b:	89 c1                	mov    %eax,%ecx
8010876d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.curr_disk;	
8010876f:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80108772:	83 c4 20             	add    $0x20,%esp
80108775:	5b                   	pop    %ebx
80108776:	5e                   	pop    %esi
80108777:	5f                   	pop    %edi
80108778:	5d                   	pop    %ebp
80108779:	c3                   	ret    

8010877a <set_name>:

void set_name(char* name, int vc_num){
8010877a:	55                   	push   %ebp
8010877b:	89 e5                	mov    %esp,%ebp
8010877d:	83 ec 08             	sub    $0x8,%esp
	strcpy(containers[vc_num].name, name);
80108780:	8b 55 0c             	mov    0xc(%ebp),%edx
80108783:	89 d0                	mov    %edx,%eax
80108785:	01 c0                	add    %eax,%eax
80108787:	01 d0                	add    %edx,%eax
80108789:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
80108790:	01 c8                	add    %ecx,%eax
80108792:	01 d0                	add    %edx,%eax
80108794:	05 f0 68 11 80       	add    $0x801168f0,%eax
80108799:	8b 40 08             	mov    0x8(%eax),%eax
8010879c:	8b 55 08             	mov    0x8(%ebp),%edx
8010879f:	89 54 24 04          	mov    %edx,0x4(%esp)
801087a3:	89 04 24             	mov    %eax,(%esp)
801087a6:	e8 d9 fd ff ff       	call   80108584 <strcpy>
}
801087ab:	c9                   	leave  
801087ac:	c3                   	ret    

801087ad <set_max_mem>:

void set_max_mem(int mem, int vc_num){
801087ad:	55                   	push   %ebp
801087ae:	89 e5                	mov    %esp,%ebp
	containers[vc_num].max_mem = mem;
801087b0:	8b 55 0c             	mov    0xc(%ebp),%edx
801087b3:	89 d0                	mov    %edx,%eax
801087b5:	01 c0                	add    %eax,%eax
801087b7:	01 d0                	add    %edx,%eax
801087b9:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
801087c0:	01 c8                	add    %ecx,%eax
801087c2:	01 d0                	add    %edx,%eax
801087c4:	8d 90 e0 68 11 80    	lea    -0x7fee9720(%eax),%edx
801087ca:	8b 45 08             	mov    0x8(%ebp),%eax
801087cd:	89 02                	mov    %eax,(%edx)
}
801087cf:	5d                   	pop    %ebp
801087d0:	c3                   	ret    

801087d1 <set_max_disk>:

void set_max_disk(int disk, int vc_num){
801087d1:	55                   	push   %ebp
801087d2:	89 e5                	mov    %esp,%ebp
	containers[vc_num].max_disk = disk;
801087d4:	8b 55 0c             	mov    0xc(%ebp),%edx
801087d7:	89 d0                	mov    %edx,%eax
801087d9:	01 c0                	add    %eax,%eax
801087db:	01 d0                	add    %edx,%eax
801087dd:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
801087e4:	01 c8                	add    %ecx,%eax
801087e6:	01 d0                	add    %edx,%eax
801087e8:	8d 90 e0 68 11 80    	lea    -0x7fee9720(%eax),%edx
801087ee:	8b 45 08             	mov    0x8(%ebp),%eax
801087f1:	89 42 08             	mov    %eax,0x8(%edx)
}
801087f4:	5d                   	pop    %ebp
801087f5:	c3                   	ret    

801087f6 <set_max_proc>:

void set_max_proc(int procs, int vc_num){
801087f6:	55                   	push   %ebp
801087f7:	89 e5                	mov    %esp,%ebp
	containers[vc_num].max_proc = procs;
801087f9:	8b 55 0c             	mov    0xc(%ebp),%edx
801087fc:	89 d0                	mov    %edx,%eax
801087fe:	01 c0                	add    %eax,%eax
80108800:	01 d0                	add    %edx,%eax
80108802:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
80108809:	01 c8                	add    %ecx,%eax
8010880b:	01 d0                	add    %edx,%eax
8010880d:	8d 90 e0 68 11 80    	lea    -0x7fee9720(%eax),%edx
80108813:	8b 45 08             	mov    0x8(%ebp),%eax
80108816:	89 42 04             	mov    %eax,0x4(%edx)
}
80108819:	5d                   	pop    %ebp
8010881a:	c3                   	ret    

8010881b <set_curr_mem>:

void set_curr_mem(int mem, int vc_num){
8010881b:	55                   	push   %ebp
8010881c:	89 e5                	mov    %esp,%ebp
	containers[vc_num].curr_mem = mem;	
8010881e:	8b 55 0c             	mov    0xc(%ebp),%edx
80108821:	89 d0                	mov    %edx,%eax
80108823:	01 c0                	add    %eax,%eax
80108825:	01 d0                	add    %edx,%eax
80108827:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
8010882e:	01 c8                	add    %ecx,%eax
80108830:	01 d0                	add    %edx,%eax
80108832:	8d 90 e0 68 11 80    	lea    -0x7fee9720(%eax),%edx
80108838:	8b 45 08             	mov    0x8(%ebp),%eax
8010883b:	89 42 0c             	mov    %eax,0xc(%edx)
}
8010883e:	5d                   	pop    %ebp
8010883f:	c3                   	ret    

80108840 <set_curr_disk>:

void set_curr_disk(int disk, int vc_num){
80108840:	55                   	push   %ebp
80108841:	89 e5                	mov    %esp,%ebp
	containers[vc_num].curr_disk = disk;
80108843:	8b 55 0c             	mov    0xc(%ebp),%edx
80108846:	89 d0                	mov    %edx,%eax
80108848:	01 c0                	add    %eax,%eax
8010884a:	01 d0                	add    %edx,%eax
8010884c:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
80108853:	01 c8                	add    %ecx,%eax
80108855:	01 d0                	add    %edx,%eax
80108857:	8d 90 f0 68 11 80    	lea    -0x7fee9710(%eax),%edx
8010885d:	8b 45 08             	mov    0x8(%ebp),%eax
80108860:	89 42 04             	mov    %eax,0x4(%edx)
}
80108863:	5d                   	pop    %ebp
80108864:	c3                   	ret    

80108865 <set_curr_proc>:

void set_curr_proc(int procs, int vc_num){
80108865:	55                   	push   %ebp
80108866:	89 e5                	mov    %esp,%ebp
	containers[vc_num].curr_proc = procs;	
80108868:	8b 55 0c             	mov    0xc(%ebp),%edx
8010886b:	89 d0                	mov    %edx,%eax
8010886d:	01 c0                	add    %eax,%eax
8010886f:	01 d0                	add    %edx,%eax
80108871:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
80108878:	01 c8                	add    %ecx,%eax
8010887a:	01 d0                	add    %edx,%eax
8010887c:	8d 90 f0 68 11 80    	lea    -0x7fee9710(%eax),%edx
80108882:	8b 45 08             	mov    0x8(%ebp),%eax
80108885:	89 02                	mov    %eax,(%edx)
}
80108887:	5d                   	pop    %ebp
80108888:	c3                   	ret    
